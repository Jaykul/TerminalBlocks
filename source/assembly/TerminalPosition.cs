namespace PoshCode
{
    public class TerminalPosition : IPsMetadataSerializable
    {
        public bool Absolute { get; set; }

        public int? Row { get; set; }

        public int? Col { get; set; }

        public TerminalPosition() {}

        public TerminalPosition(int row, int column, bool absolute = false)
        {
            Row = row;
            Col = column;
            Absolute = absolute;
        }

        public TerminalPosition(string metadata)
        {
            this.FromPsMetadata(metadata);
        }

        public override string ToString()
        {
            if (Row is null && Col is null)
            {
                return string.Empty;
            }


            if (Absolute)
            {
                // For absolute positioning, we can save by doing both
                // But if one is null, use these other absolute positioning commands
                if (Row is null)
                {
                    return "\u001b" + $"[{Col}G";
                }
                else if (Col is null)
                {
                    return "\u001b" + $"[{Row}d";
                }
                else
                {
                    return "\u001b" + $"[{Row};{Col}H";
                }
            }
            else
            {
                if (!(Col is null))
                {
                    if (Col > 0)
                    {
                        return "\u001b" + $"[{Col}C";
                    }
                    else if (Col < 0)
                    {
                        return "\u001b" + $"[{-Col}D";
                    }
                }
                if (!(Row is null))
                {
                    if (Row > 0)
                    {
                        return "\u001b" + $"[{Row}B";
                    }
                    else if (Row < 0)
                    {
                        return "\u001b" + $"[{-Row}A";
                    }
                }
            }
            return string.Empty;
        }

        public string ToPsMetadata()
        {
            return $"{Row};{Col}{(Absolute ? ";" : string.Empty)}";
        }

        public void FromPsMetadata(string metadata)
        {
            var data = metadata.Split(';');
            if (data.Length == 3)
            {
                Absolute = data[2] == "1";
            }
            if (data.Length >= 2)
            {
                Row = data[0].Length > 0 ? (int?)int.Parse(data[0], System.Globalization.NumberFormatInfo.InvariantInfo) : null;
                Col = data[1].Length > 0 ? (int?)int.Parse(data[1], System.Globalization.NumberFormatInfo.InvariantInfo) : null;
            }
        }
    }
}
