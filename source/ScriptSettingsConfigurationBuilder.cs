namespace Utilitas.PowerShell.Cmdlet
{
    using System;
    using System.Management.Automation;

    using Microsoft.Extensions.Configuration;
    
    [Cmdlet("ConvertFrom", "ScriptSettings")]
    public class ConvertFromScriptSettingsCommand : PSCmdlet
    {
        [Parameter(Mandatory = false)]
        public string ScriptSettingsFile { get; set; } = string.Empty;

        [Parameter(Mandatory = false)]
        public string Directory { get; set;} = string.Empty;

        protected override void EndProcessing()
        {
            string environment = Environment.GetEnvironmentVariable("POWERSHELLCORE_ENVIRONMENT");
            string basePath;

            IConfigurationBuilder configuration = new ConfigurationBuilder();

            if(Directory == string.Empty)
            {
                basePath = CurrentProviderLocation("FileSystem").ProviderPath;
            }
            else
            {
                basePath = Directory;
            }

            configuration.SetBasePath(basePath)
                             .AddJsonFile("scriptsettings.json", optional: true, reloadOnChange: true)
                             .AddJsonFile($"scriptsettings.{environment}.json", optional: true, reloadOnChange: true);

            if(ScriptSettingsFile != string.Empty)
            {
                configuration.AddJsonFile(ScriptSettingsFile);
            }

            var result = configuration.AddEnvironmentVariables()
                         .Build();

            /* IConfiguration configuration = new ConfigurationBuilder()
                .SetBasePath(basePath)
                .AddJsonFile("scriptsettings.json", optional: true, reloadOnChange: true)
                .AddJsonFile($"scriptsettings.{environment}.json", optional: true)
                .AddJsonFile(ScriptSettingsFile)
                .AddEnvironmentVariables()
                .Build(); */
            
            this.WriteObject(result);
            base.EndProcessing();
        }
    }
}