using Microsoft.Maui;
using Microsoft.Maui.Hosting;
using Microsoft.Extensions.DependencyInjection;

namespace HomeApp;
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder.UseMauiApp<App>();

        builder.Services.AddSingleton<IHomeService, HomeKitService>();
        builder.Services.AddTransient<MainViewModel>();
        builder.Services.AddTransient<MainPage>();

        return builder.Build();
    }
}