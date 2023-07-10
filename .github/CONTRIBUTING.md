Please read /TG/Stations contributing.md first before reading ours, 

https://github.com/tgstation/tgstation/blob/master/.github/CONTRIBUTING.md

## Welcome to TaleStation!

TaleStation is a never-ending project with a simple goal, to create an enjoyable RP experience using /TG/ code. Together, we'll make an experience everyone can enjoy.

To get started, please review the following segements (after reading /TG/s).

1. [Compiling and Modulairty](#compiling-and-modulairty)
2. [Contributing](#contributing)
3. [The Team](#the-team)
	1.[Maintainer Rules](#maintainer-rules)

## Modularity

All code should be kept modular in nature if possible. If unable to, your code MUST include the following comment(s): //NON-MODULAR CHANGES/EDIT/START/END.
If adding to a check in the main games files, try to (if possible) put your code at the end. This isn't always feesible, do it where applicable and if it works.
Images are NOT to be added to the main .dmi files. Don't do it. If you need to overwrite something, make a new .dmi file, and copy the master file if needed.

When adding files, trying to follow a similar file path as the main game. For example, if you need to extend certain vars or procs in /code/modules/carbon/, you would do the same file format in TaleStation_modules/code/modules/carbon/, this way its somewhat easier to flow through the folders and code if needed. Always start a new file with a comment stating what it is.

## Contributing

If you're unsure always ask, thats the number one rule when contributing.

If you have an idea that would benefit the upstream, we highly reccomend taking it upstream. 

If you had an idea upstream that got denied, do not attempt to open a PR. We are not a "second chance" haven. We'll cite the reason your PR was closed upstream, and close it ourselves, again.

As a rule of thumb, **do not port assets from Goon, even with permissions**. Goon is a different license than /TG/, best to avoid any conflict and/or issues.

### Sprites

As mentioned in the Modualirty section, sprites added to the main games imags (/icons/) will be required to be modularized. Failure to do so will result in your PR being closed. All images should be added to /TaleStation_modules/icons/. 

### Maps

As of 3/29/2022, there is no plans to touch the main /TG/ in-rotation maps (Box, Delta, Kilo, Meta, Tram). Touching any of these maps will result in your PR being closed.
If its a critical fix, take it upstream.

Pubby and Lima are our custom in-house maps. They are maintained by everyone, and kept up-to-date with the upstream as much as possible. Edits to these maps are permissible, but will
be kept to the /TG/ stanard. In other words, quality over quantity.

If you are **PORTING** a map from ANOTHER codebase (or even an old map from /TG/) you are **REQUIRED** to get permission from either: the map author or a maptainer. Failure to do so will result in your PR being closed. We won't hound these individuals ourselves.

## The Team

### Host & Not Host

A Byond dunce and an inept Byond coder. They run the place with tape and glue. That'll be Jolly and mcguy9123 (Patchy)

### Maintainers

Maintainers are split up into 3 catagories, Spritetainers (maintain sprites), Maptainers (maintain maps), Maintainers (maintains the code). They hold weigh on merging PRs. They call the shots, and you listen to them. Don't argue with them.

### Maintainer Rules

Maintainers are still held to the same guidelines and expectations as the rest of the contributors, however, they have elevated permissions, and as such, are expected to exercise caution and respect with their powers.

Maintainers SHOULD,
1. Be following /TG/s [precendets](https://github.com/tgstation/tgstation/blob/master/.github/CONTRIBUTING.md#maintainers) on how to act as a maintainer.
2. Be reviewing PRs in a constructive, helpful way, provide feedback when needed, and helping contributors through problems they may encounter.

- Do not merge PRs you create.
- Do not merge PRs until 24 hours have passed since it was opened. Exceptions include:
  - Emergency fixes.
    - Try to get secondary maintainer approval before merging if you are able to.
  - PRs with empty commits intended to generate a changelog.
- Do not merge PRs that contain content from the [banned content list](./CONTRIBUTING.md#banned-content).
- Do not close PRs purely for breaking a template if the same information is contained without it.

These are not steadfast rules as maintainers are expected to use their best judgement when operating.

Our team is entirely voluntary, as such we extend our thanks to maintainers, issue managers, and contributors alike for helping keep the project alive.

</details>

### Issue Managers

Issue Managers help out the project by labelling bug reports and PRs and closing bug reports which are duplicates or are no longer applicable.

<details>
<summary>What You Can and Can't Do as an Issue Manager</summary>

This should help you understand what you can and can't do with your newfound github permissions.

Things you **CAN** do:
* Label issues appropriately
* Close issues when appropriate
* Label PRs, unless you are goofball.

Things you **CAN'T** do:
* [Close PRs](https://imgur.com/w2RqpX8.png): Only maintainers are allowed to close PRs. Do not hit that button.
* Close issues purely for breaking a template if the same information is contained without it.

For more information reference the [Issue Manager Guide](.github/guides/ISSUE_MANAGER.md).

</details>

## Development Guides

#### Writing readable code 
[Style guide](./guides/STYLE.md)

#### Writing sane code 
[Code standards](./guides/STANDARDS.md)

#### Writing understandable code 
[Autodocumenting code](./guides/AUTODOC.md)

#### Misc

- [AI Datums](../code/datums/ai/learn_ai.md)
- [Embedding TGUI Components in Chat](../tgui/docs/chat-embedded-components.md)
- [Hard Deletes](./guides/HARDDELETES.md)
- [MC Tab Guide](./guides/MC_tab.md)
- [Policy Configuration System](./guides/POLICYCONFIG.md)
- [Quickly setting up a development database with ezdb](./guides/EZDB.md)
- [Required Tests (Continuous Integration)](./guides/CI.md)
- [Splitting up pull requests, aka atomization](./guides/ATOMIZATION.md)
- [UI Development](../tgui/README.md)
- [Visual Effects and Systems](./guides/VISUALS.md)

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

* Make sure your pull request complies to the requirements outlined here

* You are expected to have tested your pull requests if it is anything that would warrant testing. Text only changes, single number balance changes, and similar generally don't need testing, but anything else does. This means by extension web edits are disallowed for larger changes.

* You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data. Should you be optimizing a routine you must provide proof by way of profiling that your changes are faster.

* We ask that you use the changelog system to document your player facing changes, which prevents our players from being caught unaware by said changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* If your pull request is not finished, you may open it as a draft for potential review. If you open it as a full-fledged PR make sure it is at least testable in a live environment. Pull requests that do not at least meet this requirement will be closed. You may request a maintainer reopen the pull request when you're ready, or make a new one.

* While we have no issue helping contributors (and especially new contributors) bring reasonably sized contributions up to standards via the pull request review process, larger contributions are expected to pass a higher bar of completeness and code quality *before* you open a pull request. Maintainers may close such pull requests that are deemed to be substantially flawed. You should take some time to discuss with maintainers or other contributors on how to improve the changes.

* After leaving reviews on an open pull request, maintainers may convert it to a draft. Once you have addressed all their comments to the best of your ability, feel free to mark the pull as `Ready for Review` again.

## Justifying Your Changes

You must explain why you are submitting the pull request in the "Why It's Good For The Game" section of your pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting your pull request wholesale, or requiring that you fix it before your pull request is merged. A reasonable justification for your changes is a requirement. 

Your "Why It's Good For The Game" section must make a good faith and reasonable attempt to:
* Assert and argue that the current state of affairs in the game is not good, and needs changing.
* Assert and argue that your pull request will either fix or help fix the problems you described.
* Assert and argue that any downsides introduced by your solution as a matter of design, if any, are worth it, and why they are worth it.

More controversial changes have higher standards for justification to be considered reasonable. A bugfix for example does not typically require any effort at all in justification as its value to the game is usually self evident, however a major feature overhaul or balance change may require significant explanation to adequately justify its supposed benefit to the game.

This is still a requirement if your pull request is supported and/or requested by maintainers before it is opened. This is still a requirement if your pull request is supported and/or requested by head coders before it is opened. The purpose of arguing for your changes is not to convince just the maintainer team of its merits, it is to document the "why" behind your changes to the game to a necessary level of detail. The reason behind a change must exist as it is the purpose of this codebase to improve the game, thus said reasoning must be adequately stated and explained.

This is also still a requirement if your pull request has a corresponding design document that justifies your changes inside it. You must always properly justify changes (those that actually need justification) within the pull request, even if you also do it elsewhere. This is to ensure that:
1. All reviewers can easily see the reasoning behind your changes on the pull request itself, no reliance on other sites required.
2. The actual, manifested implementation of the idea behind the design document is being justified after said implementation is actually realized. This is in contrast to any reasoning put on the design document itself, which very well may have been made before any work was done on it, possibly even by an author different from the author of the pull request. Any idea in the design document may have had compromises put into it due to complications not seen in the original vision, thus the current state of the implementation (the pull request as it stands) must be defended, explained, and ultimately justified in and of itself. Of course, you should still list the design document the pull request is implementing, and may even use arguments from the design document if said arguments are applicable to the current reality of your proposed changes.

## Good Boy Points

Each GitHub account has a score known as Good Boy Points, or GBP. This is a system we use to ensure that the codebase stays maintained and that contributors fix bugs as well as add features.

The GBP gain or loss for a PR depends on the type of changes the PR makes, represented by the tags assigned to the PR by the tgstation github bot or maintainers. Generally speaking, fixing bugs, updating sprites, or improving maps increases your GBP score, while adding mechanics, or rebalancing things will cost you GBP.

The GBP change of a PR is the sum of greatest positive and lowest negative values it has. For example, a PR that has tags worth +10, +4, -1, -7, will net 3 GBP (10 - 7).

Negative GBP increases the likelihood of a maintainer closing your PR. With that chance being higher the lower your GBP is. Be sure to use the proper tags in the changelog to prevent unnecessary GBP loss. Maintainers reserve the right to change tags as they deem appropriate.

There is no benefit to having a higher positive GBP score, since GBP only comes into consideration when it is negative.

You can see each tag and their GBP values [Here](https://github.com/tgstation/tgstation/blob/master/.github/gbp.toml). 

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use though, porting stuff from AGPLv3 and GPLv3 codebases are allowed.

Regarding sprites & sounds, you must credit the artist and possibly the codebase. All /tg/station assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated.
<
## Banned content
Do not add any of the following in a Pull Request or risk getting the PR closed:
* National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
* Code adding, removing, or updating the availability of alien races/species/human mutants without prior approval. Pull requests attempting to add or remove features from said races/species/mutants require prior approval as well.
* Code which violates GitHub's [terms of service](https://github.com/site/terms).

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

## A word on Git
This repository uses `LF` line endings for all code as specified in the **.gitattributes** and **.editorconfig** files.

Unless overridden or a non standard git binary is used the line ending settings should be applied to your clone automatically.

Note: VSC requires an [extension](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig) to take advantage of editorconfig.

Github actions that require additional configuration are disabled on the repository until ACTION_ENABLER secret is created with non-empty value.

## Using the Maintainer Role Ping in Discord

This role `@Maintainer` is pingable as a compromise reached with the server host MrStonedOne over the auto-stale system we presently have in the codebase. It should be used only to ping Maintainers when your PR has had the "Stale" label applied. Using it before then can be met with escalating timeouts and referral to /tg/station's Discord moderators for further infractions.

Feel free to engage and obtain general feedback in the Coding General channel without the role ping before your PR goes stale to build interest and get reviews.
