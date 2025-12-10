# GitHub Copilot Instructions

## Release Workflow Requirements

When making changes to this repository, please ensure the following:

### Before Submitting Pull Requests

1. **Verify Release Action Completion**: Before submitting any pull request, ensure that the "Build and Upload Release PDF" GitHub Action completes successfully.
   
2. **Check Workflow Status**: 
   - The release workflow runs automatically on all pull requests to the `master` branch
   - Monitor the workflow run in the "Actions" tab of the repository
   - Ensure all steps complete without errors, including:
     - Checkout repository
     - Install git and Python dependencies
     - Build PDF using `make`
   
3. **Build Verification**:
   - The workflow builds the PDF document to verify that all changes compile correctly
   - Any LaTeX compilation errors or Python script failures will cause the workflow to fail
   - Fix any build errors before requesting review

### Note About Artifact Uploads

- **On Pull Requests**: The workflow will build the PDF but will NOT create tags or upload releases
- **On Master Branch**: The workflow will build the PDF AND create a new release with the generated PDF

This approach allows us to verify that changes work correctly before they are merged, without cluttering the releases with intermediate versions.

## How to Verify

1. Push your changes to a branch and create a pull request
2. Navigate to the "Actions" tab in the GitHub repository
3. Find the workflow run for your pull request
4. Wait for the "Build and Upload Release PDF" workflow to complete
5. Verify that all steps show green checkmarks
6. Only request review or merge after the workflow succeeds

## Troubleshooting

If the workflow fails:
- Check the workflow logs in the Actions tab for specific error messages
- Common issues include:
  - LaTeX compilation errors in `.tex` files
  - Python script errors in figure generation
  - Missing dependencies in `requirements.txt`
- Fix the identified issues and push new commits to re-trigger the workflow
