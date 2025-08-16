public interface IHomeService
{
    Task InitializeAsync();
    Task<IEnumerable<HomeDevice>> GetDevicesAsync();
    Task SetPowerAsync(string deviceId, bool on);
    Task<double?> GetBrightnessAsync(string deviceId);
    Task SetBrightnessAsync(string deviceId, double percent);
}
public record HomeDevice(string Id, string Name, string Room, string Category, bool? IsOn);