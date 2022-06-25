using System;
using System.Management.Automation;

namespace PoshCode
{
    public class BlockCap : IEquatable<BlockCap>, IPsMetadataSerializable
    {
        public string Left { get; set; }

        public string Right { get; set; }

        public BlockCap(string caps = null)
        {
            FromPsMetadata(caps);
        }
        public BlockCap(params object[] caps) : this(LanguagePrimitives.ConvertTo<string>(caps[0]), LanguagePrimitives.ConvertTo<string>(caps[1])) { }
        public BlockCap(string left, string right)
        {
            left = !String.IsNullOrEmpty(left) ? PoshCode.Pansies.Entities.Decode(left) : " ";
            if (right == null)
            {
                if (left.Length > 1)
                {
                    Left  = char.IsSurrogate(left, 0) ? char.ConvertFromUtf32(char.ConvertToUtf32(left, 1)) : left.Substring(0, 1);
                    Right = char.IsSurrogate(left, Left.Length) ? char.ConvertFromUtf32(char.ConvertToUtf32(left, Left.Length)) : left.Substring(Left.Length, 1);
                }
                else
                {
                    Right = Left = left;
                }
            }
            else
            {
                Left = left;
                Right = PoshCode.Pansies.Entities.Decode(right);
            }
        }

        public string ToString(BlockAlignment alignment)
        {
            // If we're right-aligned, use the right cap, and vice-versa
            return alignment == BlockAlignment.Right ? Right : Left;
        }

        // public override string ToString()
        // {
        //     // If we're right-aligned, use the right cap, and vice-versa
        //     return TerminalBlock.Alignment == BlockAlignment.Right ? Right : Left;
        // }

        public string ToPsMetadata()
        {
            return Left + "\u200D" + Right;
        }

        public void FromPsMetadata(string metadata)
        {
            metadata = !String.IsNullOrEmpty(metadata) ? PoshCode.Pansies.Entities.Decode(metadata) : " ";

            var caps = metadata.Split( new char[] { '\u200D' }, 2);
            if (caps.Length > 1)
            {
                Left = caps[0];
                Right = caps[1];
            }
            else if (metadata.Length > 1)
            {
                Left = char.IsSurrogate(metadata, 0) ? char.ConvertFromUtf32(char.ConvertToUtf32(metadata, 1)) : metadata.Substring(0, 1);
                Right = char.IsSurrogate(metadata, Left.Length) ? char.ConvertFromUtf32(char.ConvertToUtf32(metadata, Left.Length)) : metadata.Substring(Left.Length, 1);
            }
            else
            {
                Right = Left = metadata;
            }
        }

        public bool Equals(BlockCap other)
        {
            return this.Left.Equals(other.Left, StringComparison.Ordinal) && this.Right.Equals(other.Right, StringComparison.Ordinal);
        }

        public override bool Equals(object obj)
        {
            return obj is BlockCap cap && this.Left.Equals(cap.Left, StringComparison.Ordinal) && this.Right.Equals(cap.Right, StringComparison.Ordinal);
        }

        public override int GetHashCode()
        {
            return (Left + Right).GetHashCode();
        }

        public static bool operator ==(BlockCap left, BlockCap right)
        {
            return left.Equals(right);
        }

        public static bool operator !=(BlockCap left, BlockCap right)
        {
            return !(left == right);
        }
    }
}
