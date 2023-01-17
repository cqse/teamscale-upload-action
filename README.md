# Teamscale Upload

An action for uploading external analysis results (coverage, findings, …) to Teamscale. Based on [teamscale-upload](https://github.com/cqse/teamscale-upload).

# Usage 

See [action.yml](action.yml)

```yaml
- uses: 'cqse/teamscale-upload-action@v2.6.0'
    with:
      server: 'https://cqse.teamscale.io'
      project: 'teamscale-upload'
      user: 'build'
      partition: 'Github Action > Linux Branch And Timestamp'
      accesskey: ${{ secrets.ACCESS_KEY }}
      format: 'SIMPLE'
      branch-and-timestamp: 'master:HEAD'
      message: 'This is a test message.'
      files: 'test_resources/coverage.simple test_resources/coverage2.simple'
```
