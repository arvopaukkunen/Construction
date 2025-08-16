using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Runtime.CompilerServices;

public class MainViewModel : INotifyPropertyChanged
{
    private readonly IHomeService _home;
    public ObservableCollection<HomeDevice> Devices { get; } = new();

    public MainViewModel(IHomeService home) => _home = home;

    public async Task LoadAsync()
    {
        await _home.InitializeAsync();
        Devices.Clear();
        foreach (var d in await _home.GetDevicesAsync())
            Devices.Add(d);
        OnPropertyChanged(nameof(Devices));
    }

    public event PropertyChangedEventHandler? PropertyChanged;
    void OnPropertyChanged([CallerMemberName] string? name = null) =>
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(name));
}