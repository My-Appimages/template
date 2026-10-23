<img width="256" height="256" alt="Example@2x" src="https://github.com/user-attachments/assets/1445cc42-8f0b-4c86-aa47-6275616615c5" />

An template for My Appimages project that builds appimages for projects that don't have it
# How is the AppImage built
1. It runs an Github action that will run the build-appimage.sh script to build the AppImage.
3. Then after succesfully building it will create a Github release and uploads the output AppImage.

# What's the purpose of this repository?
1. To conveniently update it through [Gear Lever.](https://github.com/mijorus/gearlever)
3. To learn how AppImages are being built and distributed.

# Why reinvent the wheel?
While other platforms, already exist i made this repository purely as a learning experience and fun.

> Safety note
> This repository's Github Action workflow currently does not verify the integrity of the upstream binary. proceed with caution
> If the upstream binary or workflow ends up being compromised, the AppImage here could contain malicious code. use this at your own risk!
> The good thing is i can at least vet the binary before manually running the workflow, but security is still not guaranteed and AppImage may be out of date.

# How do i use this?
1. Clone this repository
2. Test the script if it does not work this is expected the template only succeeds on the prepare_package step its up to you to maintain the build() function
3. You might also have to configure the metadate in the config.sh file

# How do i contribute?
Contributions maintainers for this project are welcome! maintaining this just as a single person is a very difficult thing to do for multiple AppImages, so if you want to become a contributor then great! make sure you follow the contributing_rules.md before contributing to ensure my project appimages are safe!
