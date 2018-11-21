# Inspired by
# https://www.axians-infoma.com/navblog/dynamics-365-bc-extension-build-in-tfs-vsts-using-containers/
#

foreach ($ALPath in (Get-ALPaths -SetupParameters $SetupParameters)) {
    Remove-Item -Path (join-path $ALPath.FullName 'test') -Recurse -Force -ErrorAction SilentlyContinue
}    
