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
        [ThreadStatic] private static int rightPad = -1;
        [ThreadStatic] private static int lastExitCode = 0;
        [ThreadStatic] private static bool lastSuccess = true;
        [ThreadStatic] private static BlockCap cap;
        [ThreadStatic] private static BlockCap separator;

        // TODO: Document Static Properties:
        public static int LastExitCode { get => lastExitCode; set => lastExitCode = value; }
        public static bool LastSuccess { get => lastSuccess; set => lastSuccess = value; }
        public static BlockCap DefaultCap { get => cap; set => cap = value; }
        public static BlockCap DefaultSeparator { get => separator; set => separator = value; }

        public static bool Elevated { get; }
        static TerminalBlock()
        {
            DefaultCap = new BlockCap("\uE0B0", "\uE0B2");
            DefaultSeparator = new BlockCap("\uE0B1", "\uE0B3");
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
                catch {}
            }
        }

        // TODO: Document Publc Properties:
        public TerminalPosition Position { get; set; }
        public BlockAlignment Alignment { get; set; }
        public BlockCap Cap { get; set; }
        public BlockCap Separator { get; set; }
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
                else if(Elevated)
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


        private object content;
        /// <summary>
        /// Gets or sets the object.
        /// </summary>
        /// <value>A string</value>
        public object Content
        {
            get
            {
                return content;
            }
            set
            {
                var spaceTest = value.ToString();
                if (spaceTest.Equals("\n", StringComparison.Ordinal) || spaceTest.Trim().Equals("\"`n\"", StringComparison.Ordinal))
                {
                    content = BlockSpace.NewLine;
                }
                else if (spaceTest.Equals(" ", StringComparison.Ordinal) || spaceTest.Trim().Equals("\" \"", StringComparison.Ordinal))
                {
                    content = BlockSpace.Spacer;
                }
                else
                {
                    content = value;
                }
            }
        }

        /// <summary>
        /// This constructor is here so we can allow partial matches to the property names.
        /// </summary>
        /// <param name="values"></param>
        public TerminalBlock(IDictionary values) : this("")
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
                else if (Regex.IsMatch("InputObject", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("text", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("Content", pattern, RegexOptions.IgnoreCase) ||
                        Regex.IsMatch("Object", pattern, RegexOptions.IgnoreCase))
                {
                    content = values[key];
                }
                else if (Regex.IsMatch("separator", pattern, RegexOptions.IgnoreCase))
                {
                    Separator = LanguagePrimitives.ConvertTo<BlockCap>(values[key]);
                }
                else if (Regex.IsMatch("cap", pattern, RegexOptions.IgnoreCase))
                {
                    Cap = LanguagePrimitives.ConvertTo<BlockCap>(values[key]);
                }
                else if (Regex.IsMatch("alignment", pattern, RegexOptions.IgnoreCase))
                {
                    Alignment = LanguagePrimitives.ConvertTo<BlockAlignment>(values[key]);
                }
                else if (Regex.IsMatch("position", pattern, RegexOptions.IgnoreCase))
                {
                    Position = LanguagePrimitives.ConvertTo<TerminalPosition>(values[key]);
                }
                else
                {
                    throw new ArgumentException("Unknown key '" + key + "' in " + values.GetType().Name + ". Allowed values are Alignment, Position, BackgroundColor (or bg), ForegroundColor (or fg), AdminBackgroundColor (or Abg), AdminForegroundColor (or Afg), ErrorBackgroundColor (or Ebg), ErrorForegroundColor (or Efg), Separator, Cap, and Content (also called Object or Text)");
                }
            }
        }

        /// <summary>
        /// Creates a TerminalBlock that is genuinely empty (and won't output anything)
        /// Almost all PowerShell classes require the default constructor
        /// This one probably doesn't, since it has a dictionary constructor
        /// </summary>
        public TerminalBlock() : this("") { }

        /// <summary>
        /// The root constructor takes content
        /// </summary>
        public TerminalBlock(object content)
        {
            Cap = DefaultCap;
            Separator = DefaultSeparator;
            Content = content;
        }

        // TODO: Document the Cache. Normally, you should `Invoke($MyInvocation.HistoryId)` to take advantage of caching.

        /// <summary>The Cache is always EITHER a string or a BlockSpace enum</summary>
        public object Cache { get; private set; }
        public int CacheLength { get; private set; }

        private object CacheKey;
        public object Invoke(object cacheKey = null)
        {
            // null forces re-evaluation
            if (cacheKey?.Equals(CacheKey) == true)
            {
                return Cache;
            }

            if (content is BlockSpace)
            {
                CacheLength = 1;
                Cache = content;
                return content;
            }

            Cache = null;
            CacheKey = cacheKey ?? String.Empty;
            if (!(Content is null))
            {

                Cache = Entities.Decode(ConvertToString(Content));
                if (string.IsNullOrEmpty(Cache?.ToString()))
                {
                    Cache = null;
                }
            }

            // The length includes the length of the cap, if any
            CacheLength = Cache != null ? _escapeCode.Replace(Cache.ToString(), "").Length + _escapeCode.Replace(Cap?.ToString(Alignment) ?? "", "").Length : 0;

            return Cache;
        }

        private string ConvertToString(object content, string separator = " ")
        {
            if (content != null)
            {
                string s = content as string;
                ScriptBlock sb = null;
                IEnumerable enumerable = null;
                // strings are IEnumerable, so we special case them
                if (s != null && s.Length > 0)
                {
                    return s;
                }
                else if ((enumerable = content as IEnumerable) != null)
                {
                    // unroll enumerables, including arrays.

                    bool printSeparator = false;
                    StringBuilder result = new StringBuilder();

                    foreach (object element in enumerable)
                    {
                        if (printSeparator == true)
                        {
                            result.Append(Separator?.ToString(Alignment) ?? " ");
                        }

                        result.Append(ConvertToString(element, separator));
                        printSeparator = true;
                    }

                    return result.ToString();
                }
                else if (!((sb = content as ScriptBlock) is null))
                {
                    return ConvertToString(sb.Invoke(), separator);
                }
                else
                {
                    s = content.ToString();

                    if (s.Length > 0)
                    {
                        return s;
                    }
                }
            }

            return null;
        }


        public override string ToString()
        {
            return GetString(ForegroundColor, BackgroundColor, Invoke(null), Alignment, Cap?.ToString(Alignment));
        }

        public string ToLine(RgbColor otherBackground = null, object cacheKey = null)
        {
            string output = GetString(ForegroundColor, BackgroundColor, Invoke(cacheKey), Alignment, Cap?.ToString(Alignment), otherBackground);

            if (Alignment == BlockAlignment.Right && CacheLength > 0)
            {
                var prefix = "";
                //if (rightPad == -1)
                //{
                    prefix = $"\u001B[{Console.BufferWidth}G";
                //}
                rightPad += CacheLength;

                return prefix + $"\u001B[{rightPad}D" + Position?.ToString() + output;
            }
            else if (CacheLength > 0)
            {
                // currently right-aligned, so make a new line
                if (rightPad >= 0)
                {
                    rightPad = -1;
                    return "\n" + Position?.ToString() + output;
                }
                return Position?.ToString() + output;
            }

            return output;
        }

        private static string GetString(RgbColor foreground, RgbColor background, object content, BlockAlignment alignment = BlockAlignment.Left, string cap = null, RgbColor otherBackground = null)
        {
            if (content is null) {
                return null;
            }

            if (content is BlockSpace space)
            {
                switch (space)
                {
                    case BlockSpace.Spacer:
                        cap = "\u001b[7m" + cap + "\u001b[27m";
                        content = string.Empty;
                        background = otherBackground;
                        foreground = otherBackground = null;
                        break;
                    case BlockSpace.NewLine:
                        return "\n";
                }
            }

            var output = new StringBuilder();

            if (cap != null && alignment == BlockAlignment.Right)
            {
                if (null != otherBackground)
                {
                    output.Append(otherBackground.ToVtEscapeSequence(true));
                }
                if (null != background)
                {
                    output.Append(background.ToVtEscapeSequence(false));
                }
                output.Append(cap);
                // clear foreground
                output.Append("\u001b[39m");
            }

            var color = new StringBuilder();
            if (null != foreground)
            {
                // There was a bug in Conhost where an advanced 48;2 RGB code followed by a console code wouldn't render the RGB value
                // So we try to put the ConsoleColor first, if it's there ...
                if (foreground.Mode == ColorMode.ConsoleColor)
                {
                    color.Append(foreground.ToVtEscapeSequence(false));
                    if (null != background)
                    {
                        color.Append(background.ToVtEscapeSequence(true));
                    }
                }
                else
                {
                    if (null != background)
                    {
                        color.Append(background.ToVtEscapeSequence(true));
                    }
                    color.Append(foreground.ToVtEscapeSequence(false));
                }
            }
            else if (null != background)
            {
                color.Append(background.ToVtEscapeSequence(true));
            }

            output.Append(color?.ToString());
            output.Append(content?.ToString());

            if (cap != null && alignment == BlockAlignment.Left)
            {
                // clear background
                output.Append("\u001B[49m");
                if (null != otherBackground)
                {
                    output.Append(otherBackground.ToVtEscapeSequence(true));
                }
                if (null != background)
                {
                    output.Append(background.ToVtEscapeSequence(false));
                }
                output.Append(cap);
            }

            return Pansies.Entities.Decode(output.ToString()) + "\u001B[0m";
        }

        public bool Equals(TerminalBlock other)
        {
            return other != null &&
                (Content == other.Content &&
                    ForegroundColor == other.ForegroundColor &&
                    BackgroundColor == other.BackgroundColor) &&
                (Alignment == other.Alignment) &&
                (Separator == null && other.Separator == null || Separator.Equals(other.Separator)) &&
                (Cap == null && other.Cap == null || Cap.Equals(other.Cap));
        }

        public string ToPsMetadata() {

            var objectString = string.Empty;
            // ToDictionary and Constructor handle single-character strings (with quotes) for PromptSpace
            if (Content is BlockSpace space)
            {
                objectString = "\" \"";
                switch (space)
                {
                    case BlockSpace.Spacer:
                        objectString = "\" \"";
                        break;
                    case BlockSpace.NewLine:
                        objectString = "\"`n\"";
                        break;
                }
            }
            else if (Content is ScriptBlock script)
            {
                objectString = "(ScriptBlock '" + script.ToString().Replace("\'","\'\'") + "')";
            }
            else
            {
                objectString = "\'" + Content.ToString().Replace("\'", "\'\'") + "\'";
            }

            return  "@{" +
                    (DefaultForegroundColor is null ? "" : $"\nDFg='{DefaultForegroundColor}'") +
                    (DefaultBackgroundColor is null ? "" : $"\nDBg='{DefaultBackgroundColor}'") +
                    (ErrorForegroundColor is null ? "" : $"\nEFg='{ErrorForegroundColor}'") +
                    (ErrorBackgroundColor is null ? "" : $"\nEBg='{ErrorBackgroundColor}'") +
                    (AdminForegroundColor is null ? "" : $"\nAFg='{AdminForegroundColor}'") +
                    (AdminBackgroundColor is null ? "" : $"\nABg='{AdminBackgroundColor}'") +
                    (Position is null ? "" : "\nPosition='" + Position.ToPsMetadata() + "'") +
                    (Separator is null ? "" : "\nSeparator='" + Separator.ToPsMetadata() + "'") +
                    (Cap is null ? "" : "\nCap='" + Cap.ToPsMetadata() + "'") +
                    (Alignment == BlockAlignment.Left ? "" : $"\nAlignment='{Alignment}'") +
                    "\nContent=" + objectString +
                    "\n}";
        }

        public string ToPsScript()
        {

            var objectString = string.Empty;
            // ToDictionary and Constructor handle single-character strings (with quotes) for PromptSpace
            if (Content is BlockSpace space)
            {
                objectString = "\" \"";
                switch (space)
                {
                    case BlockSpace.Spacer:
                        objectString = "\" \"";
                        break;
                    case BlockSpace.NewLine:
                        objectString = "\"`n\"";
                        break;
                }
            }
            else if (Content is ScriptBlock script)
            {
                objectString = "{" + script.ToString() + "}";
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
                    (Separator is null ? "" : " -Separator '" + Separator.ToPsMetadata() + "'") +
                    (Cap is null ? "" : " -Cap '" + Cap.ToPsMetadata() + "'") +
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
