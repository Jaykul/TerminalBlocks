namespace PoshCode
{
    // Two rules for IPSMetadataSerializable:
    // There should be a parameterless constructor
    // FromPsMetadata needs to handle the output of ToPsMetadata
    public interface IPsMetadataSerializable
    {
        string ToPsMetadata();
        void FromPsMetadata(string metadata);
    }
}
