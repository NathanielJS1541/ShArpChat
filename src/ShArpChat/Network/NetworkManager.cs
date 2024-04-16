using System.Net;
using System.Net.NetworkInformation;

namespace ShArpChat.Network
{
    public class NetworkManager
    {
        public NetworkManager()
        {

        }

        public static ArpClient GetArpClientForNetwork(IPEndPoint interfaceIp)
        {
            return new ArpClient(interfaceIp);
        }

        public static IEnumerable<NetworkInterface> GetSupportedInterfaces()
        {
            var networkInterfaces = new List<NetworkInterface>();

            var interfaces = System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
                .Where(network => network is { SupportsMulticast: true, OperationalStatus: OperationalStatus.Up, NetworkInterfaceType: NetworkInterfaceType.Ethernet or NetworkInterfaceType.GigabitEthernet or NetworkInterfaceType.Wireless80211 });

            foreach (var netInterface in interfaces)
            {
                networkInterfaces.Add(new NetworkInterface(netInterface));
            }

            return networkInterfaces;
        }
    }
}
