# Teamscale Upload

An action for uploading external analysis results (coverage, findings, …) to Teamscale. Based on [teamscale-upload](https://github.com/cqse/teamscale-upload).

# Usage 

See [action.yml](action.yml)

```yaml
- uses: 'cqse/teamscale-upload-action@v1.0.0'
    with:
      version: 'v2.3.0'
      server: 'https://demo.teamscale.com'
      project: 'teamscale-upload'
      user: 'build'
      partition: 'Github Action > Linux Branch And Timestamp'
      accesskey: ${{ secrets.ACCESS_KEY }}
      format: 'SIMPLE'
      branch-and-timestamp: 'master:HEAD'
      message: 'This is a test message.'
      files: 'test_resources/coverage.simple test_resources/coverage2.simple'
```
