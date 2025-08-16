#nullable enable
using HomeKit;
using Foundation;
using System.Linq;

public sealed class HomeKitService : NSObject, IHomeService, IHMHomeManagerDelegate
{
    private readonly HMHomeManager _manager = new HMHomeManager();
    private TaskCompletionSource<bool> _ready = new();

    public HomeKitService() => _manager.Delegate = this;

    [Export("homeManagerDidUpdateHomes:")]
    public void DidUpdateHomes(HMHomeManager manager)
    {
        if (!_ready.Task.IsCompleted) _ready.TrySetResult(true);
    }

    public async Task InitializeAsync() => await _ready.Task;

    public async Task<IEnumerable<HomeDevice>> GetDevicesAsync()
    {
        await InitializeAsync();
        var home = _manager.PrimaryHome ?? _manager.Homes.FirstOrDefault();
        if (home is null) return Enumerable.Empty<HomeDevice>();
        return home.Accessories.Select(a => new HomeDevice(
            Id: a.Identifier?.ToString() ?? Guid.NewGuid().ToString(),
            Name: a.Name,
            Room: a.Room?.Name ?? "Unknown",
            Category: a.Category?.LocalizedDescription ?? a.Category?.ToString() ?? "Device",
            IsOn: a.Services.SelectMany(s => s.Characteristics)
                 .FirstOrDefault(c => c.CharacteristicType == HMCharacteristicType.PowerState)?.Value is NSNumber n ? n.BoolValue : null
        ));
    }

    public async Task SetPowerAsync(string deviceId, bool on)
    {
        await InitializeAsync();
        var acc = _manager.Homes.SelectMany(h => h.Accessories).FirstOrDefault(a => a.Identifier?.ToString() == deviceId);
        var ch = acc?.Services.SelectMany(s => s.Characteristics)
                   .FirstOrDefault(c => c.CharacteristicType == HMCharacteristicType.PowerState);
        ch?.WriteValue(NSNumber.FromBoolean(on), (err) => { });
    }

    public Task<double?> GetBrightnessAsync(string deviceId)
    {
        var acc = _manager.Homes.SelectMany(h => h.Accessories).FirstOrDefault(a => a.Identifier?.ToString() == deviceId);
        var ch = acc?.Services.SelectMany(s => s.Characteristics)
                   .FirstOrDefault(c => c.CharacteristicType == HMCharacteristicType.Brightness);
        double? value = null;
        ch?.ReadValue((err) => { value = ch?.Value is NSNumber n ? n.DoubleValue : null; });
        return Task.FromResult(value);
    }

    public Task SetBrightnessAsync(string deviceId, double percent)
    {
        var acc = _manager.Homes.SelectMany(h => h.Accessories).FirstOrDefault(a => a.Identifier?.ToString() == deviceId);
        var ch = acc?.Services.SelectMany(s => s.Characteristics)
                   .FirstOrDefault(c => c.CharacteristicType == HMCharacteristicType.Brightness);
        ch?.WriteValue(NSNumber.FromDouble(Math.Clamp(percent, 0, 100)), (err) => {});
        return Task.CompletedTask;
    }
}