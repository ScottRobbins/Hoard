# Hoard

A simple tool to allow backing up files to a git repository and keeping them in sync across multiple computers. 

1. [Installation](#installation)
2. [Usage](#usage)
3. [Using with multiple computers](#using-with-multiple-computers)
4. [Working with secrets](#working-with-secrets)

### Installation

To build and install locally:

```console
$ ./install_release.sh
```

### Usage

**Initialize .hoardconfig**

Go to the root of your git repo and run: 

```console
$ hoard init
```

This will create a `~/.hoardconfig` file, with the first file listed in the config being the config itself (meta, I know).

**Add some files to your config** 

```console
$ hoard add my_file.txt
Enter identifier for file (press enter to use filename as identifier): my_file_identifier
```

This will add that file to your `.hoardconfig`. The identifier you choose will uniquely identify this file in your git repo.

**Back up your files**

```console
$ hoard collect
```

This will copy all of the files in your `.hoardconfig` into your git repo, commit the changes, and push to remote. You can also specify not to push using the `--push=false` option.

**Distribute files from your git repo**

```console
$ hoard distribute
```

This will pull from your git repository and use your `.hoardconfig` to move the files listed in it from the git repository to the locations specified. It will overwrite any of those files that were on your local filesystem, but will make a copy of them at their location + `_hoardcopy`. This is just a simple safety net in case you accidentally overwrite a local file that had unsaved changes. 

### Using with multiple computers

One of the main uses of this tool is to back up things like dotfiles. 

When using multiple machines, there are usually some dotfiles that you want to share across computers (ex: `.gitconfig`, `.vimrc`). You may also have some dotfiles that are specific to a machine (perhaps things that are only relevant for a work computer but not a personal computer). In order to make this work with multiple computers, you would have 2 **different** `.hoardconfig` files on your computers that are specific to that machine. They can have different paths in the filesystem to where files should be collected/distributed from/to, and they can omit any files that aren't relevant to that machine. 

A common dotfile that contains both information you want to share across computers and information specific to a single computer is a `.zshrc` or `.bashrc` file. You might have tool setup and aliases useful on multiple machines, and other aliases that are specific to the work being done on a specific machine. In this case, you can split out the common functionality into a separate shell script that you source from your `.zshrc`/`.bashrc`. 

### Working with secrets

**Don't. Commit. Unencrypted. Secrets. To. Git.**

That means you need to make sure you don't have any secrets in the dotfiles you want to back up. If they are in your `.zshrc`/`.bashrc`, you can split those secrets into a separate shell file and source it from your `.zshrc`/`.bashrc` and then just backup your `.zshrc`/`.bashrc`. 

You may want to consider using a tool to detect git secrets in your repo before they are pushed. (Ex: [git-secrets](https://github.com/awslabs/git-secrets). **DISCLAIMER: I have not used this tool and am not endorsing it, was just something i found online**).