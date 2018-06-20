if ($SetupParameters.BuildMode) {
    Compile-ObjectsInNavContainer -containerName $BranchSettings.dockerContainerName -filter $SetupParameters.objectFilter
}