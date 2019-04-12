# culture="en-US"
ConvertFrom-StringData @'
    ImportingSourceFile               = Importing source '{0}'.
    TestingGit                        = Testing Git.
    TestingGitRepository              = Testing Git repository '{0}'.
    QueryingGitCommitCount            = Querying Git commit count.
    RunningGitCommand                 = Running Git command 'git.exe {0}'.
    ParsingGitCommandOutput           = Parsing Git command output '{0}'.
    DetectedGitVersion                = Detected Git version '{0}'.
    CloningGitRepository              = Cloning Git repository '{0}'.
    UpdatingGitRepository             = Updating Git repository '{0}'.
    QueryingGitRemote                 = Querying Git remote.
    GitRemoteFound                    = Git remote '{0}' found.
    FilePathExcluded                  = File path '{0}' has been manually excluded by '{1}'.
    DirectoryPathExcluded             = Directory path '{0}' has been manually excluded by '{1}'.
    CheckingForExcludedFile           = Checking for excluded file '{0}'.
    NoGitIgnoreFound                  = No valid .gitignore found in path '{0}'.
    NoGitAttributesFound              = No valid .gitattributes found in path '{0}'.
    OpeningMsiDatabase                = Opening MSI database '{0}'.
    StartingProcessWithArgs           = Starting process '{0} {1}'.

    FileNotFoundOrDirectoryWarning    = File path '{0}' was not found or was a directory.
    NoFileEncodingFoundWarning        = No encoding detected for file path '{0}'; assuming ASCII encoding.

    GitNotFoundError                  = Git was not found or is not in the system path.
    GitRepositoryNotFoundError        = Path '{0}' does not contain a valid Git repository.
    GitRepositoryFoundError           = Path '{0}' already contains a Git repository.
    GitRemoteNotConfiguredError       = Git repository does not have a remote origin configured.
    InvalidCertificateThumbprintError = Invalid certificate thumbprint '{0}.
    SigningFileError                  = Error signing file '{0}'.
    NotFilePathError                  = Path '{0}' is not a valid file path.
    NotDirectoryPathError             = Path '{0}' is not a valid directory path.
    NotGitHubRemoteOriginError        = Remote origin '{0}' does not appear to be a Github repository.
    NoMatchingManifestFileError       = No manifest file matching '{0}' found.
    MulitpleManifestFilesFoundError   = Mulitple manifest files found in '{0}' found.
    FileExistsError                   = File '{0}' already exists.
    DirectoryPathSpecifyNupkgError    = Path '{0}' is a directory. Please specify a valid .nupkg file.
    DirectoryPathSpecifyNuspecError   = Path '{0}' is a directory. Please specify a valid .nuspec file.
    InvalidNupkgPathError             = Path '{0}' is not a .nupkg file. Please specify a valid .nupkg file.
    InvalidNuspecPathError            = Path '{0}' is not a .nupkg file. Please specify a valid .nuspec file.
    ProjectUriNotDefinedError         = PrivateData.PSData.ProjectUri is not defined in the module manifest.
'@
