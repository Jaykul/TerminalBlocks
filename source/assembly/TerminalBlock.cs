using System;
using System.Collections;
using System.Collections.Generic;
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
        private Regex _escapeCode = new Regex("\u001B\\P{L}+\\p{L}", RegexOptions.Compiled);
        [ThreadStatic] private static int __rightPad = -1;
        [ThreadStatic] private static int __lastExitCode = 0;
        [ThreadStatic] private static bool __lastSuccess = true;
        [ThreadStatic] private static string __separator;
        [ThreadStatic] private static BlockCaps __leftCaps;
        [ThreadStatic] private static BlockCaps __rightCaps;

        // TODO: Document Static Properties:
        public static int LastExitCode { get => __lastExitCode; set => __lastExitCode = value; }
        public static bool LastSuccess { get => __lastSuccess; set => __lastSuccess = value; }
        public static BlockCaps DefaultCapsLeftAligned { get => __leftCaps; set => __leftCaps = value; }
        public static BlockCaps DefaultCapsRightAligned { get => __rightCaps; set => __rightCaps = value; }
        public static String DefaultSeparator { get => __separator; set => __separator = value; }

        public static bool Elevated { get; }
        static TerminalBlock()
        {
            // By default, no caps
            DefaultCapsLeftAligned = new BlockCaps("", " ");
            DefaultCapsRightAligned = new BlockCaps(" ", "");
            DefaultSeparator = " ";
            try
            {
                Elevated = WindowsIdentity.GetCurrent().Owner.IsWellKnown(WellKnownSidType.BuiltinAccountOperatorsSid);
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
        public TerminalPosition Position { get; set; }
        public BlockAlignment Alignment {
            get => alignment;
            set {
                alignment = value;
                if (Caps is null)
                {
                    Caps = value == BlockAlignment.Left ? DefaultCapsLeftAligned : DefaultCapsRightAligned;
                }
            }
        }
        public BlockCaps Caps { get; set; }
        public String MyInvocation { get; set; }
        public String Separator { get; set; }
        public String Prefix { get; set; }
        public String Postfix { get; set; }
        public RgbColor AdminForegroundColor { get; set; }
        public RgbColor AdminBackgroundColor { get; set; }
        public RgbColor ErrorForegroundColor { get; set; }
        public RgbColor ErrorBackgroundColor { get; set; }
        public RgbColor DefaultForegroundColor { get; set; }
        public RgbColor DefaultBackgroundColor { get; set; }

        public RgbColor ForegroundColor
        {
            get
            {
                if (!LastSuccess)
                {
                    return ErrorForegroundColor ?? DefaultBackgroundColor;
                }
                else if (Elevated)
                {
                    return AdminForegroundColor ?? DefaultBackgroundColor;
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
                if ("Abg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("AdminBackgroundColor", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch("ElevatedBackgroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    AdminBackgroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("Afg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("AdminForegroundColor", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch("ElevatedForegroundColor", pattern, RegexOptions.IgnoreCase))
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
                else if ("bg".Equals(key, StringComparison.OrdinalIgnoreCase) || "Dbg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("DefaultBackgroundColor", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch("BackgroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    BackgroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if ("fg".Equals(key, StringComparison.OrdinalIgnoreCase) || "Dfg".Equals(key, StringComparison.OrdinalIgnoreCase) || Regex.IsMatch("DefaultForegroundColor", pattern, RegexOptions.IgnoreCase) || Regex.IsMatch("ForegroundColor", pattern, RegexOptions.IgnoreCase))
                {
                    ForegroundColor = RgbColor.ConvertFrom(values[key]);
                }
                else if (Regex.IsMatch("Content", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("InputObject", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("text", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("Object", pattern, RegexOptions.IgnoreCase))
                {
                    _content = values[key];
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
                else if (Regex.IsMatch("alignment", pattern, RegexOptions.IgnoreCase))
                {
                    Alignment = LanguagePrimitives.ConvertTo<BlockAlignment>(values[key]);
                }
                else if (Regex.IsMatch("position", pattern, RegexOptions.IgnoreCase))
                {
                    Position = LanguagePrimitives.ConvertTo<TerminalPosition>(values[key]);
                }
                else if (Regex.IsMatch("MyInvocation", pattern, RegexOptions.IgnoreCase))
                {
                    MyInvocation = LanguagePrimitives.ConvertTo<String>(values[key]);
                }
                else if (Regex.IsMatch(key, "persist|entities", RegexOptions.IgnoreCase))
                {
                    // I once had these properties, but I don't anymore
                }
                else
                {
                    throw new ArgumentException("Unknown key '" + key + "' in " + values.GetType().Name + ". Allowed values are Alignment, Position, BackgroundColor (or bg), ForegroundColor (or fg), AdminBackgroundColor (or Abg), AdminForegroundColor (or Afg), ErrorBackgroundColor (or Ebg), ErrorForegroundColor (or Efg), Separator, Caps, Content (also called Object or Text), Prefix and Postfix");
                }
            }

            if (Caps is null)
            {
                Caps = Alignment == BlockAlignment.Left ?
                    DefaultCapsLeftAligned : DefaultCapsRightAligned;
            }
        }

        /// <summary>
        /// The default constructor is required for serialization
        /// </summary>
        public TerminalBlock() {}
        /// <summary>
        /// The root constructor takes content
        /// </summary>
        public TerminalBlock(object content)
        {
            Caps = DefaultCapsLeftAligned;
            Separator = DefaultSeparator;
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
                    CacheLength = _escapeCode.Replace((string)_cache, "").Length +
                                    (Caps is null ? 0 : Caps.Length);
                }
            }
        }
        public int CacheLength { get; private set; }

        private object _cacheKey;
        private object _cache;
        private BlockAlignment alignment;

        public object Invoke(object cacheKey = null)
        {
            // null forces re-evaluation
            if (cacheKey?.Equals(_cacheKey) == true)
            {
                return Cache;
            }
            _cacheKey = cacheKey ?? String.Empty;

            if (Content is SpecialBlock)
            {
                return Content;
            }

            var cacheable = ReInvoke(Content);
            if (string.IsNullOrEmpty(cacheable))
            {
                Cache = null;
            }
            else
            {
                Cache = Prefix + cacheable + Postfix;
            }

            return Cache;
        }

        private string ReInvoke(object content)
        {
            switch (content)
            {
                case null:
                    return null;
                case String s:
                    return string.IsNullOrEmpty(s) ? null : Entities.Decode(s);
                case ScriptBlock sb:
                    return ReInvoke(sb.Invoke());
                case IEnumerable enumerable:
                    bool printSeparator = false;
                    StringBuilder result = new StringBuilder();

                    foreach (object element in enumerable)
                    {
                        var e = ReInvoke(element);
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
                default:
                    string stringContent = content.ToString();
                    return string.IsNullOrEmpty(stringContent) ? null : stringContent;
            }
        }

        public override string ToString() => ToString(position: true);

        public string ToString(bool position = false, RgbColor otherBackground = null, object cacheKey = null)
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
                        content = "\u001b[7m" + Caps[Alignment] + "\u001b[27m";
                        background = otherBackground;
                        foreground = otherBackground = null;
                        break;
                    case SpecialBlock.StorePosition:
                        return "\u001b[s";
                    case SpecialBlock.RecallPosition:
                        return "\u001b[u";
                    case SpecialBlock.NewLine:
                        return "\n";
                }
            }

            var output = new StringBuilder();

            // If there's no length, there's no output, so no position
            if (position)
            {
                if (Alignment == BlockAlignment.Right)
                {
                    __rightPad += CacheLength;
                    output.Append($"\u001B[{Console.BufferWidth}G");
                    output.Append($"\u001B[{__rightPad}D");
                }
                // currently right-aligned, so make a new line
                else if (__rightPad >= 0)
                {
                    __rightPad = -1;
                    output.Insert(0, '\n');
                }
                Position?.AppendTo(output);
            }

            if (!string.IsNullOrEmpty(Caps?.Left))
            {
                // use otherBackground, and this background as foreground
                otherBackground?.AppendTo(output, true);
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
                output.Append("\u001B[49m");
                // use otherBackground, and this background as foreground
                otherBackground?.AppendTo(output, true);
                background?.AppendTo(output, false);
                output.Append(Caps.Right);
            }

            // clear formatting
            output.Append("\u001B[0m");

            return Entities.Decode(output.ToString());
        }


        public bool Equals(TerminalBlock other)
        {
            return other != null &&
                (Content == other.Content &&
                    ForegroundColor == other.ForegroundColor &&
                    BackgroundColor == other.BackgroundColor) &&
                (Alignment == other.Alignment) &&
                (Separator == null && other.Separator == null || Separator.Equals(other.Separator)) &&
                (Caps == null && other.Caps == null || Caps.Equals(other.Caps));
        }

        public string ToPsMetadata()
        {

            var objectString = string.Empty;
            // ToDictionary and Constructor handle single-character strings (with quotes) for PromptSpace
            if (Content is SpecialBlock space)
            {
                objectString = "\" \"";
                switch (space)
                {
                    case SpecialBlock.Spacer:
                        objectString = "\" \"";
                        break;
                    case SpecialBlock.NewLine:
                        objectString = "\"`n\"";
                        break;
                }
            }
            else if (Content is ScriptBlock script)
            {
                objectString = "(ScriptBlock '" + script.ToString().Replace("\'", "\'\'") + "')";
            }
            else
            {
                objectString = "\'" + Content.ToString().Replace("\'", "\'\'") + "\'";
            }

            return "@{" +
                    (DefaultForegroundColor is null ? "" : $"\nDFg='{DefaultForegroundColor}'") +
                    (DefaultBackgroundColor is null ? "" : $"\nDBg='{DefaultBackgroundColor}'") +
                    (ErrorForegroundColor is null ? "" : $"\nEFg='{ErrorForegroundColor}'") +
                    (ErrorBackgroundColor is null ? "" : $"\nEBg='{ErrorBackgroundColor}'") +
                    (AdminForegroundColor is null ? "" : $"\nAFg='{AdminForegroundColor}'") +
                    (AdminBackgroundColor is null ? "" : $"\nABg='{AdminBackgroundColor}'") +
                    (Position is null ? "" : "\nPosition='" + Position.ToPsMetadata() + "'") +
                    (Separator is null ? "" : "\nSeparator='" + Separator + "'") +
                    (Caps is null ? "" : "\nCap='" + Caps.ToPsMetadata() + "'") +
                    (Alignment == BlockAlignment.Left ? "" : $"\nAlignment='{Alignment}'") +
                    "\nContent=" + objectString +
                    "\n}";
        }

        public string ToPsScript()
        {
            if (!string.IsNullOrEmpty(MyInvocation))
            {
                return MyInvocation;
            }

            var objectString = string.Empty;
            // ToDictionary and Constructor handle single-character strings (with quotes) for PromptSpace
            if (Content is SpecialBlock space)
            {
                objectString = "\" \"";
                switch (space)
                {
                    case SpecialBlock.Spacer:
                        objectString = "\" \"";
                        break;
                    case SpecialBlock.NewLine:
                        objectString = "\"`n\"";
                        break;
                }
            }
            else if (Content is ScriptBlock script)
            {
                objectString = "(ScriptBlock '" + script.ToString().Replace("\'", "\'\'") + "')";
            }
            else
            {
                objectString = "\'" + Content.ToString().Replace("\'", "\'\'") + "\'";
            }

            return "New-TerminalBlock" +
                    (DefaultForegroundColor is null ? "" : $" -DFg '{DefaultForegroundColor}'") +
                    (DefaultBackgroundColor is null ? "" : $" -DBg '{DefaultBackgroundColor}'") +
                    (ErrorForegroundColor is null ? "" : $" -EFg '{ErrorForegroundColor}'") +
                    (ErrorBackgroundColor is null ? "" : $" -EBg '{ErrorBackgroundColor}'") +
                    (AdminForegroundColor is null ? "" : $" -AFg '{AdminForegroundColor}'") +
                    (AdminBackgroundColor is null ? "" : $" -ABg '{AdminBackgroundColor}'") +
                    (Position is null ? "" : " -Position '" + Position.ToPsMetadata() + "'") +
                    (Separator is null ? "" : " -Separator '" + Separator + "'") +
                    (Caps is null ? "" : " -Cap '" + Caps.ToPsMetadata() + "'") +
                    (Alignment == BlockAlignment.Left ? "" : $" -Alignment '{Alignment}'") +
                    " -Content " + objectString;
        }

        public void FromPsMetadata(string metadata)
        {
            var ps = PowerShell.Create(RunspaceMode.CurrentRunspace);
            var languageMode = ps.Runspace.SessionStateProxy.LanguageMode;
            Hashtable data;
            try
            {
                ps.Runspace.SessionStateProxy.LanguageMode = PSLanguageMode.RestrictedLanguage;
                ps.AddScript(metadata, true);
                data = ps.Invoke<Hashtable>().FirstOrDefault();

                FromDictionary(data);
            }
            finally
            {
                ps.Runspace.SessionStateProxy.LanguageMode = languageMode;
            }
        }
    }
}
