using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using System.Security.Principal;
using System.Text;
using System.Text.RegularExpressions;
using PoshCode.Pansies;
using System.Runtime.InteropServices;

namespace PoshCode
{
    static class NativeMethods
    {
        [DllImport("libc")]
        internal static extern uint getuid();

        [DllImport("libc")]
        internal static extern uint geteuid();
    }

    public class TerminalBlock : IPsMetadataSerializable
    {
        // Borrowed this from https://github.com/chalk/ansi-regex
        // private Regex _escapeCode = new Regex("[\\u001b\\u009b][[\\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]+)*|[a-zA-Z\\d]+(?:;[-a-zA-Z\\d\\/#&.:=?%@~_]*)*)?\\u0007)|(?:(?:\\d{1,4}(?:;\\d{0,4})*)?[\\dA-PR-TZcf-nq-uy=><~]))", RegexOptions.Compiled);

        // starting with an escape character and then...
        // ESC ] <anything> <ST> - where ST is either 1B 5C or 7 (BEL, aka `a)
        // ESC [ non-letters letter (or ~, =, @, >)
        // ESC ( <any character>
        // ESC O P
        // ESC O Q
        // ESC O R
        // ESC O S

        private Regex _escapeCode = new Regex("\\x1b[\\(\\)%\"&\\.\\/*+.-][@-Z]|\\x1b\\].*?(?:\\u001b\\u005c|\\u0007|^)|\\x1b\\[\\P{L}*[@-_A-Za-z^`\\{\\|\\}~]|\\x1b#\\d|\\x1b[!-~]", RegexOptions.Compiled);
        //[ThreadStatic] private static int? __lastExitCode;
        //[ThreadStatic] private static bool? __lastSuccess;
        [ThreadStatic] private static string __separator;
        [ThreadStatic] private static BlockCaps __caps;
        [ThreadStatic] private static SessionState __globalSessionState;

        // TODO: Document Static Properties:
        public static int LastExitCode { get => (int)__globalSessionState.PSVariable.GetValue("LastExitCode"); }
        public static bool LastSuccess { get => (bool)__globalSessionState.PSVariable.GetValue("?"); }
        public static BlockCaps DefaultCaps { get => __caps; set => __caps = value; }
        public static String DefaultSeparator { get => __separator; set => __separator = value; }
        public static SessionState GlobalSessionState { get => __globalSessionState; set => __globalSessionState = value; }

        public static bool Elevated { get; }
        static TerminalBlock()
        {
            // By default, no caps
            DefaultCaps = new BlockCaps("", "");
            DefaultSeparator = " ";
            try
            {
                // Elevated = WindowsIdentity.GetCurrent().Owner.IsWellKnown(WellKnownSidType.BuiltinAdministratorsSid);
                Elevated = new WindowsPrincipal(WindowsIdentity.GetCurrent()).IsInRole(WindowsBuiltInRole.Administrator);
            }
            catch
            {
                try
                {
                    Elevated = 0 == NativeMethods.getuid();
                }
                catch { }
            }
        }

        // TODO: Document Public Properties:

        public BlockCaps Caps { get; set; } = DefaultCaps;
        public String MyInvocation { get; set; }
        public String Separator { get; set; } = DefaultSeparator;
        public String Prefix { get; set; }
        public String Postfix { get; set; }
        public bool HadErrors { get; set; }
        public PSDataStreams Streams { get; set; }
        public RgbColor AdminForegroundColor
        {
            get => _adminForegroundColor;
            set
            {
                _adminForegroundColor = value;

                if (!string.IsNullOrEmpty(MyInvocation))
                {
                    // Everything which sets MyInvocation has the New-TerminalBlock parameters, so we'll try to update it...
                    var Replaced = Regex.Replace(MyInvocation, @"-(AdminForegroundColor|AdminFg|AFg)\s+[^\s]+", "-$1 '" + value.ToString() + "'", RegexOptions.IgnoreCase);
                    if (Replaced.Equals(MyInvocation, StringComparison.Ordinal))
                    {
                        MyInvocation = MyInvocation + " -AFg '" + value.ToString() + "'";
                    }
                    else
                    {
                        MyInvocation = Replaced;
                    }
                }
            }
        }
        public RgbColor AdminBackgroundColor
        {
            get => _adminBackgroundColor;
            set
            {
                _adminBackgroundColor = value;

                if (!string.IsNullOrEmpty(MyInvocation))
                {
                    // Everything which sets MyInvocation has the New-TerminalBlock parameters, so we'll try to update it...
                    var Replaced = Regex.Replace(MyInvocation, @"-(AdminBackgroundColor|AdminBg|ABg)\s+[^\s]+", "-$1 '" + value.ToString() + "'", RegexOptions.IgnoreCase);
                    if (Replaced.Equals(MyInvocation, StringComparison.Ordinal))
                    {
                        MyInvocation = MyInvocation + " -ABg '" + value.ToString() + "'";
                    } else {
                        MyInvocation = Replaced;
                    }
                }
            }
        }
        public RgbColor ErrorForegroundColor
        {
            get => _errorForegroundColor;
            set
            {
                _errorForegroundColor = value;

                if (!string.IsNullOrEmpty(MyInvocation))
                {
                    // Everything which sets MyInvocation has the New-TerminalBlock parameters, so we'll try to update it...
                    var Replaced = Regex.Replace(MyInvocation, @"-(ErrorForegroundColor|ErrorFg|EFg)\s+[^\s]+", "-$1 '" + value.ToString() + "'", RegexOptions.IgnoreCase);
                    if (Replaced.Equals(MyInvocation, StringComparison.Ordinal))
                    {
                        MyInvocation = MyInvocation + " -EFg '" + value.ToString() + "'";
                    } else {
                        MyInvocation = Replaced;
                    }
                }
            }
        }
        public RgbColor ErrorBackgroundColor
        {
            get => _errorBackgroundColor;
            set
            {
                _errorBackgroundColor = value;

                if (!string.IsNullOrEmpty(MyInvocation))
                {
                    // Everything which sets MyInvocation has the New-TerminalBlock parameters, so we'll try to update it...
                    var Replaced = Regex.Replace(MyInvocation, @"-(ErrorBackgroundColor|ErrorBg|EBg)\s+[^\s]+", "-$1 '" + value.ToString() + "'", RegexOptions.IgnoreCase);
                    if (Replaced.Equals(MyInvocation, StringComparison.Ordinal))
                    {
                        MyInvocation = MyInvocation + " -EBg '" + value.ToString() + "'";
                    } else {
                        MyInvocation = Replaced;
                    }
                }
            }
        }
        public RgbColor DefaultForegroundColor
        {
            get => _defaultForegroundColor;
            set
            {
                _defaultForegroundColor = value;

                if (!string.IsNullOrEmpty(MyInvocation))
                {
                    var stringColor = "$null";
                    if (null != value)
                    {
                        stringColor = value.ToString();
                    }

                    // Everything which sets MyInvocation has the New-TerminalBlock parameters, so we'll try to update it...
                    var Replaced = Regex.Replace(MyInvocation, @"-((?:Default)?ForegroundColor|D?Fg)\s+[^\s]+", "-$1 '" + stringColor + "'", RegexOptions.IgnoreCase);
                    if (Replaced.Equals(MyInvocation, StringComparison.Ordinal))
                    {
                        MyInvocation = MyInvocation + " -Fg '" + stringColor + "'";
                    } else {
                        MyInvocation = Replaced;
                    }
                }
            }
        }
        public RgbColor DefaultBackgroundColor
        {
            get => _defaultBackgroundColor;
            set
            {
                _defaultBackgroundColor = value;

                if (!string.IsNullOrEmpty(MyInvocation))
                {
                    var stringColor = "$null";
                    if (null != value) {
                        stringColor = value.ToString();
                    }
                    // Everything which sets MyInvocation has the New-TerminalBlock parameters, so we'll try to update it...
                    var Replaced = Regex.Replace(MyInvocation, @"-((?:Default)?BackgroundColor|D?Bg)\s+[^\s]+", "-$1 '" + stringColor + "'", RegexOptions.IgnoreCase);
                    if (Replaced.Equals(MyInvocation, StringComparison.Ordinal))
                    {
                        MyInvocation = MyInvocation + " -Fg '" + stringColor + "'";
                    } else {
                        MyInvocation = Replaced;
                    }
                }
            }
        }
        public RgbColor ForegroundColor
        {
            get
            {
                if (!LastSuccess && null != ErrorForegroundColor)
                {
                    return ErrorForegroundColor;
                }
                else if (Elevated && null != AdminForegroundColor)
                {
                    return AdminForegroundColor;
                }
                else
                {
                    return DefaultForegroundColor;
                }
            }
            set
            {
                DefaultForegroundColor = value;
            }
        }
        public RgbColor BackgroundColor
        {
            get
            {
                if (!LastSuccess && null != ErrorBackgroundColor)
                {
                    return ErrorBackgroundColor;
                }
                else if (Elevated && null != AdminBackgroundColor)
                {
                    return AdminBackgroundColor;
                }
                else
                {
                    return DefaultBackgroundColor;
                }
            }
            set
            {
                DefaultBackgroundColor = value;
            }
        }

        private object _content;
        /// <summary>
        /// Gets or sets the object.
        /// </summary>
        /// <value>A string</value>
        public object Content
        {
            get
            {
                return _content;
            }
            set
            {
                var spaceTest = value.ToString();
                if (spaceTest.Equals("\n", StringComparison.Ordinal) || spaceTest.Trim().Equals("\"`n\"", StringComparison.Ordinal))
                {
                    _content = SpecialBlock.NewLine;
                }
                else if (spaceTest.Equals(" ", StringComparison.Ordinal) || spaceTest.Trim().Equals("\" \"", StringComparison.Ordinal))
                {
                    _content = SpecialBlock.Spacer;
                }
                else
                {
                    _content = value;
                }
            }
        }

        /// <summary>
        /// This constructor is here so we can allow partial matches to the property names.
        /// </summary>
        /// <param name="values"></param>
        public TerminalBlock(IDictionary values)
        {
            // Caps = DefaultCaps;
            // Separator = DefaultSeparator;
            FromDictionary(values);
        }

        /// <summary>
        /// This supports the IDictionary constructor *and* FromPSMetadata serialization
        /// </summary>
        /// <param name="values"></param>
        private void FromDictionary(IDictionary values)
        {
            foreach (string key in values.Keys)
            {
                var pattern = "^" + Regex.Escape(key);
                if ("Abg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("AdminBackgroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    AdminBackgroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("Afg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("AdminForegroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    AdminForegroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("Ebg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("ErrorBackgroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    ErrorBackgroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("Efg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("ErrorForegroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    ErrorForegroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("Bg".Equals(key, StringComparison.OrdinalIgnoreCase) || "DBg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("DefaultBackgroundColor", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch("BackgroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    BackgroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("Fg".Equals(key, StringComparison.OrdinalIgnoreCase) || "DFg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("DefaultForegroundColor", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch("ForegroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    ForegroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if (Regex.IsMatch("Content", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("InputObject", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("text", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("Object", pattern, RegexOptions.IgnoreCase))
                {
                    Content = values[key];
                }
                else if (Regex.IsMatch("separator", pattern, RegexOptions.IgnoreCase))
                {
                    Separator = LanguagePrimitives.ConvertTo<String>(values[key]);
                }
                else if (Regex.IsMatch("prefix", pattern, RegexOptions.IgnoreCase))
                {
                    Prefix = LanguagePrimitives.ConvertTo<String>(values[key]);
                }
                else if (Regex.IsMatch("postfix", pattern, RegexOptions.IgnoreCase))
                {
                    Postfix = LanguagePrimitives.ConvertTo<String>(values[key]);
                }
                else if (Regex.IsMatch("caps", pattern, RegexOptions.IgnoreCase))
                {
                    Caps = LanguagePrimitives.ConvertTo<BlockCaps>(values[key]);
                }
                else if (Regex.IsMatch("MyInvocation", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch(key, "persist|entities", RegexOptions.IgnoreCase))
                {
                    // I once had these properties, but I don't anymore
                }
                else
                {
                    throw new ArgumentException("Unknown key '" + key + "' in " + values.GetType().Name + ". Allowed values are Alignment, Position, BackgroundColor (or bg), ForegroundColor (or fg), AdminBackgroundColor (or Abg), AdminForegroundColor (or Afg), ErrorBackgroundColor (or Ebg), ErrorForegroundColor (or Efg), Separator, Caps, Content (also called Object or Text), Prefix and Postfix");
                }
            }

            // Set MyInvocation last, to avoid having it updated by the property setters
            if (values.Contains("MyInvocation")) {

                MyInvocation = LanguagePrimitives.ConvertTo<String>(values["MyInvocation"]);
            }
        }

        /// <summary>
        /// The default constructor is required for serialization
        /// </summary>
        public TerminalBlock() { }
        /// <summary>
        /// The root constructor takes content
        /// </summary>
        public TerminalBlock(object content)
        {
            // Caps = DefaultCaps;
            // Separator = DefaultSeparator;
            Content = content;
        }

        // TODO: Document the Cache. Normally, you should `Invoke($MyInvocation.HistoryId)` to take advantage of caching.

        /// <summary>The Cache is always EITHER: null, a string, or a SpecialBlock enum</summary>

        public object Cache
        {
            get => _cache;
            private set
            {
                if (value is null)
                {
                    _cache = value;
                    CacheLength = 0;
                }
                else if (value is SpecialBlock)
                {
                    _cache = value;
                    CacheLength = Caps is null ? 0 : Caps.Length;
                }
                else
                {
                    _cache = Entities.Decode((string)value);

                    CacheLength = (new StringInfo(_escapeCode.Replace((string)_cache, ""))).LengthInTextElements +
                                    (Caps is null ? 0 : Caps.Length);
                }
            }
        }
        public int CacheLength { get; private set; }

        private object _cacheKey;
        private object _cache;
        private RgbColor _defaultBackgroundColor;
        private RgbColor _defaultForegroundColor;
        private RgbColor _errorBackgroundColor;
        private RgbColor _errorForegroundColor;
        private RgbColor _adminBackgroundColor;
        private RgbColor _adminForegroundColor;

        public object Invoke(object cacheKey = null)
        {
            // null forces re-evaluation
            if (cacheKey?.Equals(_cacheKey) == true)
            {
                return Cache;
            }

            // SpecialBlock don't need to be rendered or affixed
            if (Content is SpecialBlock)
            {
                return Content;
            }

            string cacheContent = Render(Content);
            _cacheKey = cacheKey ?? String.Empty;
            if (string.IsNullOrEmpty(cacheContent))
            {
                Cache = null;
            }
            else
            {
                Cache = Prefix + cacheContent + Postfix;
            }

            return Cache;
        }

        private string Render(object content)
        {
            switch (content)
            {
                case null:
                    return null;
                // Rendering a string just means decoding entities
                case String s:
                    return string.IsNullOrEmpty(s) ? null : Entities.Decode(s);
                // Rendering arrays means rendering each one with Separator between them
                case IEnumerable enumerable:
                    // Don't print a separator before the first element
                    bool printSeparator = false;
                    StringBuilder result = new StringBuilder();

                    foreach (object element in enumerable)
                    {
                        var e = Render(element);
                        if (!string.IsNullOrEmpty(e))
                        {
                            if (printSeparator == true)
                            {
                                result.Append(Separator);
                            }
                            result.Append(e);
                        }
                        printSeparator = true;
                    }

                    return result.ToString();
                // Most things are scriptblocks, which means we need to invoke them
                case ScriptBlock sb:
                    try
                    {
                        PowerShell powershell = PowerShell.Create(RunspaceMode.CurrentRunspace);
                        IList<object> output = new List<object>();
                        this.Streams = powershell.Streams;
                        this.Streams.ClearStreams();
                        powershell.AddScript("param($content) & $content").AddParameter("content", sb);
                        try
                        {
                            powershell.Invoke(null, output);
                        }
                        catch (Exception ex)
                        {
                            this.Streams.Error.Add(new ErrorRecord(ex, "ExceptionFromScriptBlock", ErrorCategory.InvalidArgument, sb));
                        }
                        this.HadErrors = powershell.HadErrors;
                        //
                        return Render(output);
                    }
                    catch (Exception ex)
                    {   // I'm no longer sure under what circumstances this might happen
                        this.HadErrors = true;
                        if (this.Streams == null)
                        {
                            PowerShell powershell = PowerShell.Create();
                            this.Streams = powershell.Streams;
                        }
                        this.Streams.Error.Add(new ErrorRecord(ex, "CannotInvokeOnCurrentRunspace", ErrorCategory.InvalidArgument, sb));
                        return Render(sb.Invoke());
                    }

                default:
                    string stringContent = content.ToString();
                    return string.IsNullOrEmpty(stringContent) ? null : stringContent;
            }
        }

        public override string ToString() => ToString(null, null, null);

        // new overload requires two "other" background colors (one for each end cap).
        public string ToString(RgbColor leftBackground, RgbColor rightBackground, object cacheKey = null)
        {
            var content = Invoke(cacheKey);
            if (content is null)
            {
                return null;
            }

            var background = BackgroundColor;
            var foreground = ForegroundColor;

            if (content is SpecialBlock space)
            {
                switch (space)
                {
                    case SpecialBlock.Spacer:
                        var spacer = new StringBuilder();
                        foreground?.AppendTo(spacer, true);
                        if (!string.IsNullOrEmpty(Caps.Left))
                        {
                            (leftBackground ?? background)?.AppendTo(spacer);
                            spacer.Append("\u001b[7m" + Caps.Left + "\u001b[27m");
                        }
                        else if (!string.IsNullOrEmpty(Caps.Right))
                        {
                            (rightBackground ?? background)?.AppendTo(spacer);
                            spacer.Append("\u001b[7m" + Caps.Right + "\u001b[27m");
                        }
                        // clear formatting
                        spacer.Append("\u001b[0m");
                        return spacer.ToString();
                    case SpecialBlock.StorePosition:
                        return "\u001b[s";
                    case SpecialBlock.RecallPosition:
                        return "\u001b[u";
                    case SpecialBlock.NewLine:
                        return "\n";
                }
            }

            var output = new StringBuilder();

            if (!string.IsNullOrEmpty(Caps?.Left))
            {
                leftBackground?.AppendTo(output, true);
                background?.AppendTo(output, false);
                output.Append(Caps.Left);
                // clear foreground
                output.Append("\u001b[39m");
            }

            background?.AppendTo(output, true);
            foreground?.AppendTo(output, false);
            output.Append((string)content);

            if (!string.IsNullOrEmpty(Caps?.Right))
            {
                // clear background
                output.Append("\u001b[49m");
                // use rightBackground, and this background as foreground
                rightBackground?.AppendTo(output, true);
                // nextBackground?.AppendTo(output, true);
                background?.AppendTo(output, false);
                output.Append(Caps.Right);
            }

            // clear formatting
            output.Append("\u001b[0m");

            return Entities.Decode(output.ToString());
        }

        public bool Equals(TerminalBlock other)
        {
            return other != null &&
                (Content == other.Content &&
                    ForegroundColor == other.ForegroundColor &&
                    BackgroundColor == other.BackgroundColor) &&
                (Separator == null && other.Separator == null || Separator.Equals(other.Separator, StringComparison.OrdinalIgnoreCase)) &&
                (Caps == null && other.Caps == null || Caps.Equals(other.Caps));
        }

        public string ToPsMetadata()
        {
            if (!string.IsNullOrEmpty(MyInvocation))
            {
                return MyInvocation;
            }
            string contentString = ContentToPsScript(Content);
            if (contentString.Length > 1 && contentString[0] != ' ')
            {
                contentString = " -Content " + contentString;
            }

            return "New-TerminalBlock" +
                    (Caps is null || Caps.Equals(DefaultCaps) ? "" : " -Cap \'" + Caps.ToPsMetadata() + "\'") +
                    (string.IsNullOrEmpty(Separator) || Separator.Equals(DefaultSeparator, StringComparison.Ordinal) ? "" : $" -Separator \'{Separator}\'") +
                    (DefaultForegroundColor is null ? "" : $" -Fg \'{DefaultForegroundColor}\'") +
                    (DefaultBackgroundColor is null ? "" : $" -Bg \'{DefaultBackgroundColor}\'") +
                    (ErrorForegroundColor is null ? "" : $" -EFg \'{ErrorForegroundColor}\'") +
                    (ErrorBackgroundColor is null ? "" : $" -EBg \'{ErrorBackgroundColor}\'") +
                    (AdminForegroundColor is null ? "" : $" -AFg \'{AdminForegroundColor}\'") +
                    (AdminBackgroundColor is null ? "" : $" -ABg \'{AdminBackgroundColor}\'") +
                    contentString;
        }

        private string ContentToPsScript(object content) {
            switch (content)
            {
                case null:
                    return "$null";
                // Rendering a string just means decoding entities
                case String s:
                    return string.IsNullOrEmpty(s) ? "" : "\'" + content.ToString().Replace("\'", "\'\'") + "\'";
                // Rendering arrays means rendering @(,)
                case IEnumerable enumerable:
                    bool printSeparator = false;
                    StringBuilder result = new StringBuilder("@(");

                    foreach (object element in enumerable)
                    {
                        var e = ContentToPsScript(element);
                        if (!string.IsNullOrEmpty(e))
                        {
                            if (printSeparator == true)
                            {
                                result.Append(',');
                            }
                            result.Append(e);
                        }
                        printSeparator = true;
                    }
                    result.Append(')');
                    return result.ToString();

                // ToDictionary and Constructor handle single-character strings (with quotes) for PromptSpace
                case SpecialBlock space:
                    switch (space)
                    {
                        case SpecialBlock.Spacer:
                            return " -Spacer";
                        case SpecialBlock.NewLine:
                            return " -NewLine";
                        case SpecialBlock.StorePosition:
                            return " -StorePosition";
                        case SpecialBlock.RecallPosition:
                            return " -RecallPosition";
                    }
                    break;
                case ScriptBlock script:
                    // The terrifying scriptblock hack
                    return "'{" + script.ToString().Replace("\'", "\'\'") + "}'";
            }
            return string.Empty;
        }

        public void FromPsMetadata(string metadata)
        {
            var ps = PowerShell.Create(RunspaceMode.CurrentRunspace);
            var languageMode = ps.Runspace.SessionStateProxy.LanguageMode;
            TerminalBlock data;
            try
            {
                ps.Runspace.SessionStateProxy.LanguageMode = PSLanguageMode.RestrictedLanguage;
                ps.AddScript(metadata, true);
                data = ps.Invoke<TerminalBlock>().FirstOrDefault();

                Caps = data.Caps;
                MyInvocation = data.MyInvocation;
                Separator = data.Separator;
                Prefix = data.Prefix;
                Postfix = data.Postfix;

                if (null != data.AdminBackgroundColor)
                {
                    AdminBackgroundColor = data.AdminBackgroundColor;
                }
                if (null != data.AdminForegroundColor)
                {
                    AdminForegroundColor = data.AdminForegroundColor;
                }
                if (null != data.ErrorBackgroundColor)
                {
                    ErrorBackgroundColor = data.ErrorBackgroundColor;
                }
                if (null != data.ErrorForegroundColor)
                {
                    ErrorForegroundColor = data.ErrorForegroundColor;
                }
                if (null != data.DefaultBackgroundColor)
                {
                    DefaultBackgroundColor = data.DefaultBackgroundColor;
                }
                if (null != data.DefaultForegroundColor)
                {
                    DefaultForegroundColor = data.DefaultForegroundColor;
                }

                Content = data.Content;

            }
            finally
            {
                ps.Runspace.SessionStateProxy.LanguageMode = languageMode;
            }
        }
    }
}
