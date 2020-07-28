# Halfje-Bruin.nl Blog

This is the source and content of my blog visible at [Halfje-Bruin.nl](https://halfje-bruin.nl). It uses [Hugo](https://gohugo.io/) to generate the static pages and a modified version of the [Hugo Future Imperfect Slim](https://github.com/pacollins/hugo-future-imperfect-slim) theme for the layout.

## Setup

Clone or download the sources from [here](https://github.com/kdbruin/halfje-bruin.nl):

```shell
cd ~/Sites
git clone https://github.com/kdbruin/halfje-bruin.nl
```

Next, add the modified theme:

```shell
cd halfje-bruin.nl/themes
git clone https://github.com/kdbruin/hugo-future-imperfect-slim
```

Add the original repository as `upstream` so we can trach any changes:

```shell
cd hugo-future-imperfect-slim
git remote add --track master upstream https://github.com/pacollins/hugo-future-imperfect-slim.git
```

## Local development

To run a local server use the following command:

```shell
cd ~/Sites/halfje-bruin.nl
hugo server -D --disableFastRender
```

The website can be viewed at http://localhost:1313/.

## Merging upstream changes

To update the modified theme with upstream changes we need to change to the proper branch first:

```shell
git checkout master
```

Next, retrieve all changes from the upstream repository:

```shell
git fetch upstream
```

To merge the changes use the following command:

```shell
git merge upstream/master
```

After fixing possible merge conflicts the changes are push to the local repository only. To push to the remote repository use:

```shell
git push
```
