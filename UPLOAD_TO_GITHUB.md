# Upload Doosan Modules to GitHub

## 1. Create the repository

Open the pre-filled repository form:

https://github.com/new?owner=ZwartIndustrial&name=Doosan-Modules&description=Doosan+DART+modules+from+Zwart+Industrial+Innovations

Use these settings:

- Owner: `ZwartIndustrial`
- Repository name: `Doosan-Modules`
- Description: `Doosan DART modules from Zwart Industrial Innovations`
- Visibility: **Public** when the modules must be downloadable without signing in.
- Do not add another README, `.gitignore`, or licence because they are already included.

## 2. Upload the repository files

Upload the complete contents of this `Doosan-Modules` folder to the empty repository.

Suggested commit message:

```text
Add PlcData 0.0.1 Doosan module
```

## 3. Create the PlcData release

1. Open `https://github.com/ZwartIndustrial/Doosan-Modules/releases`.
2. Click **Draft a new release**.
3. Create the tag `plcdata-v0.0.1`.
4. Use the release title `PlcData 0.0.1`.
5. Copy the contents of `PlcData/RELEASE_NOTES_0.0.1.md` into the description.
6. Attach `PlcData/release/com.zii.plcdata_0.0.1.dm` as a release asset.
7. Attach `PlcData/PlcData_User_Manual_v0.0.1.pdf` as a release asset.
8. Publish the release.

## 4. Future modules and versions

- Add every new module in its own top-level folder.
- Use module-prefixed tags, for example `plcdata-v0.0.2` or `anothermodule-v1.0.0`.
- Update the module's `CHANGELOG.md`, release notes, download file, and manual together.
- Update the module table in the repository `README.md`.
