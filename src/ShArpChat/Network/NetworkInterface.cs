using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;

namespace ShArpChat.Network
{
    public class NetworkInterface
    {
        public string Name { get; }

        public PhysicalAddress PhysicalAddress { get; }

        public string PhysicalAddressAsString => PhysicalAddress.ToString();

        public IPAddress Address { get; }

        public bool IsAddressValid => !Equals(Address, IPAddress.None);

        public NetworkInterface(System.Net.NetworkInformation.NetworkInterface baseInterface)
        {
            Name = baseInterface.Name;
            PhysicalAddress = baseInterface.GetPhysicalAddress();

            var properties = baseInterface.GetIPProperties();
            Address = properties.UnicastAddresses.FirstOrDefault(address => address.Address.AddressFamily == AddressFamily.InterNetwork)?.Address ?? IPAddress.None;
        }
    }
}