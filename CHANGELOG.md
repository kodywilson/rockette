## [Unreleased]

## [0.0.0] - 2021-02-08

- Initial release


## [0.0.1] - 2021-03-15

- Unify rest calls into Rester class
- Improve exception handling including socket errors
- Switch to yaml for config
- Use ~/.rockette as consistent location for config and exports

## [0.0.2] - 2021-03-18

- Add copy switch to deploy command
- Use file name passed via -f switch
- Try to find export file and let caller know if file not found

## [0.0.3] - 2021-03-29

- Improved handling of copy and file switches
- Check /usr/app for Docker
- Add interactive mode
- Add configuration option to interactive mode
- Add resource viewer mode to interactive
- Add exporter option to interactive
- Add deployer mode to interactive

## [0.0.4] - 2021-03-29

- Bug fix for APP_DIR