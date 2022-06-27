using System;
using System.Text;
using PoshCode.Pansies;

namespace PoshCode
{
    internal static class StringBuilderExtension
    {
        // These exist to shorten stuff like this:
        //      if (color is not null) { StringBuilder.Append(color); }
        // To this:
        //      color?.AppendString(builder)
        public static void AppendTo(this RgbColor color, StringBuilder builder, bool background = false) {
            builder.Append(color.ToVtEscapeSequence(background));
        }

        public static void AppendTo(this TerminalPosition position, StringBuilder builder)
        {
            builder.Append(position);
        }
    }
}
