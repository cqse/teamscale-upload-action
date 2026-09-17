# Teamscale Upload

An action for uploading external analysis results (coverage, findings, …) and vulnerability reports to Teamscale. Based on [teamscale-upload](https://github.com/cqse/teamscale-upload).

# Usage

See [action.yml](action.yml) for all available inputs.

The `command` input selects what to upload. Leave it unset to upload external analysis results, so existing workflows keep working unchanged.

## Uploading external analysis results

```yaml
- uses: 'cqse/teamscale-upload-action@v2.11.0'
    with:
      server: 'https://cqse.teamscale.io'
      project: 'teamscale-upload'
      user: 'build'
      partition: 'Github Action > Linux Branch And Timestamp'
      accesskey: ${{ secrets.ACCESS_KEY }}
      format: 'SIMPLE'
      message: 'This is a test message.'
      files: 'test_resources/coverage.simple test_resources/coverage2.simple'
```

## Uploading a vulnerability report

Uploads a vulnerability report, e.g. a Software Bill of Materials (SBOM). Requires Teamscale 2026.7.0 or later.

Teamscale stores one report per `build-name` and `build-version`, so `files` must resolve to exactly one file. Uploading again with the same `build-name` and `build-version` overwrites the previously uploaded report. Neither may contain `#`, which Teamscale uses internally as a separator.

```yaml
- uses: 'cqse/teamscale-upload-action@v2.11.0'
    with:
      command: 'vulnerability-report'
      server: 'https://cqse.teamscale.io'
      project: 'teamscale-upload'
      user: 'build'
      accesskey: ${{ secrets.ACCESS_KEY }}
      build-name: 'my-service'
      build-version: ${{ github.run_number }}
      files: 'bom.json'
```
