# SharePoint Migration Framework

## Summary

This solution contains two Plaster-Templates that allow you to create new SharePoint-Projects using a migration-like approach. The other template creates new migrations to an existing project.

## Prerequisits
- [Plaster](https://github.com/PowerShell/Plaster)
- [SharePoint PnP-Powershell >= 3](https://github.com/SharePoint/PnP-PowerShell)
- SharePoint 2013 / ~~2016~~ / Office365

## Usage

```powershell
Invoke-Plaster -TemplatePath [Path-to-Plaster-Template]
```

### New-Project Parameters
| Parameter | Description |
| ---|--- |
| TemplatePath | path, where the plaster-template is stored
| DestinationPath | path, where the new project should be created
| SiteUrl | URL of the site, where the migration should be executed against
| FieldName | name of the property, where the current deployment-version will be stored
| Edition | the edition to use, either `2013`, ~~`2016`~~ or `online`

### Add-Migration Parameters
| Parameter | Description |
| ---|--- |
| TemplatePath | path, where the plaster-template is stored
| DestinationPath | path, where the new project should be created