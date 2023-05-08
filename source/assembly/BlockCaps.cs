using System;
using System.Globalization;
using System.Management.Automation;

namespace PoshCode
{
    public class BlockCaps : IEquatable<BlockCaps>, IPsMetadataSerializable
    {
        public string Left { get; set; }

        public string Right { get; set; }

        // For IPSMetadataSerializable to work
        // Also supports hashtable construction
        public BlockCaps() {}
        // For string casting to work
        public BlockCaps(string caps = null) => FromPsMetadata(caps);
        // For array (of string) casting to work
        public BlockCaps(params object[] caps) : this(LanguagePrimitives.ConvertTo<string>(caps[0]), LanguagePrimitives.ConvertTo<string>(caps[1])) { }

        // The only actual constructor that explicitly sets everything
        public BlockCaps(string left, string right)
        {
            left = !String.IsNullOrEmpty(left) ? PoshCode.Pansies.Entities.Decode(left) : string.Empty;
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

        public int Length {
            get {
                return (Left is null ? 0 : new StringInfo(Left).LengthInTextElements) + (Right is null ? 0 : new StringInfo(Right).LengthInTextElements);
            }
        }
        public string this[BlockEnd end] {
            get {
                if (end == BlockEnd.Left)
                {
                    return Left;
                }
                else
                {
                    return Right;
                }
            }
            set {
                if (end == BlockEnd.Left)
                {
                    Left = value;
                }
                else
                {
                    Right = value;
                }
            }
        }

        public string ToPsMetadata()
        {
            return Left + "\u200D" + Right;
        }

        public void FromPsMetadata(string metadata)
        {
            metadata = !String.IsNullOrEmpty(metadata) ? PoshCode.Pansies.Entities.Decode(metadata) : string.Empty;

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

        public bool Equals(BlockCaps other)
        {
            return this.Left.Equals(other.Left, StringComparison.Ordinal) && this.Right.Equals(other.Right, StringComparison.Ordinal);
        }

        public override bool Equals(object obj)
        {
            return obj is BlockCaps cap && this.Left.Equals(cap.Left, StringComparison.Ordinal) && this.Right.Equals(cap.Right, StringComparison.Ordinal);
        }

        public override int GetHashCode()
        {
            return (Left + Right).GetHashCode();
        }

        public static bool operator ==(BlockCaps left, BlockCaps right)
        {
            return left.Equals(right);
        }

        public static bool operator !=(BlockCaps left, BlockCaps right)
        {
            return !(left == right);
        }
    }
}
