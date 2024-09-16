---
title: self-hosting is exciting
published: 2024-08-13
aliases:
- self-hosting is exciting
---

# self-hosting is exciting

I have grown dissatisfied with some of the software and services I use on a daily basis. Even when attempting to use VPS services to host the things I want to use, I have often found that the VPS's that are offered do not match my needs. This is because I often need a server that doesn't have a lot of computational power because I'm more or less the only user but _does_ have lots of storage because I have a lot of data I want to save.

Aside from the price and logistics, there are also privacy concerns I have. So, I have been looking into self-hosted alternatives and found myself with some potential solutions for the things that I use. Recently, I remembered that I could self-host my own server without exposing it to the public internet by using a VPN. This made me really excited, to the point that I even did a stream where [I built an insane NAS configuration](https://vods.exodrifter.space/2024/08/11/2008) and I've been talking about or researching self-hosting more or less all day the last few days.

At the suggestion of a user on my Discord server, I will document all of the prospective tools I have chosen and why I have chosen them below.

---

# VPN

**[Tailscale](https://tailscale.com/)** is a proprietary E2EE VPN tool that lets you connect multiple computers together into a private network and [securely share nodes in your private network with other users](https://tailscale.com/kb/1084/sharing). It does so with zero-configuration and is extremely easy to set up. They have a generous free tier intended for personal use which allows up to 3 users and 100 devices. Their code is also _almost_ entirely open-source, and hosted on GitHub at [tailscale/tailscale](https://github.com/tailscale/tailscale). This is the only software choice I've made that isn't completely open source.

In particular, a VPN is very important piece of the puzzle because it allows me to self-host a server that I can access from pretty much anywhere in the world as long as I have an internet connection. The fact that I own the hardware lets me side-step problems like needing to avoid tools that don't encrypt files at rest (because I don't want my VPS provider to see my files) or having to pay a really large VPS bill (because cloud storage is expensive, something I will address more when I talk about file syncing tools). I also have a lot of hardware leftover from old PC builds, so I can probably build an acceptably performant NAS server without too much effort.

It allows me to host servers in a way that my family can access without exposing that server to the public. It also lets me connect all of my personal devices together for use with Syncthing without, again, needing to expose any of my computers publicly. This is a relief because I'm pretty sure I would have trouble securing my server in such an environment and a failure in doing so would result in a lot of personal information being leaked and or stolen. In a similar fashion, I'm not actually _that_ interested in self-hosting my own VPN due to the concern that I might not do a good job securing a VPN server that is exposed to the public internet.

Alternatives include:
- **[Headscale](https://headscale.net/)**: This open-source implementation of Tailscale's control server actually has, as one of its main contributors, a software engineer by the name of [Kristoffer Dalby](https://kradalby.no/) who also works at Tailscale. It even works with the official Tailscale apps. Unfortunately, at the moment the process for connecting to a Headscale control server requires some [additional technical steps for Windows users](https://github.com/juanfont/headscale/blob/022fb24cd92035470496d50d86bf8c9ee74b1e7e/docs/windows-client.md) that I would have trouble getting my less technically-savvy family members to set up and maintain on their own.
- **[Netbird](https://github.com/netbirdio/netbird)**: Netbird is very similar to Tailscale and offers many of the same features. Their free tier is also more generous, allowing up to 5 users and 100 devices. Notably, it is also _completely_ open source, which allows you to self-host unlike Tailscale. However, the use cases listed on their website seem more work-oriented. I only learned about this while writing this post, so I might explore this option more later and choose it if I need to have more users in my network. That seems unlikely to happen in the near future since I've already learned how to use Tailscale and Tailscale is mostly open-source anyway.
- **[Wireguard](https://www.wireguard.com/)**: Both Tailscale and Netbird actually use Wireguard under the hood to make connections. You could use this instead if you weren't interested in the mesh networking and are happy to manually configure each connection to your other devices. However, Tailscale is so easy to set up and use that even if I wasn't interested in mesh networking, I'm reluctant to spend the time to learn how to use Wireguard.

# Photos

**[Immich](https://immich.app/)** is a great tool for organizing personal photos. Previously, I had been storing all of my photos in Dropbox, but Dropbox doesn't do a very good job of letting you organize and view your photos, so I never looked at them. It can easily handle thousands of images and has great features including face detection, multi-user support, "On this day..." photos, and free-form text search. I also appreciate that one of the design goals of Immich is to _never_ modify the original photo; changes to the photo's metadata are instead written to a separate file. If you're familiar with Google Photos, you'll find that Immich is quite similar. There's also an Android/iOS app which will automatically backup your photos to your Immich server.

Unfortunately, Immich isn't quite stable yet. It is also missing quite a few features that I could really use and it has several issues like incorrectly dealing with time data. However, it is undergoing rapid development with a full-time development team and has an active community. It is easily the best photo management tool I've used in a long time and it's quite easy to set up if you have some technical knowledge.

Some other alternatives include:
- [PhotoPrism](https://www.photoprism.app/): I didn't like how this application advertises itself as "AI-powered". While Immich also uses AI, it's used as a means to help me organize and search my data which I think is a good use of AI. PhotoPrism, on the other hand, has a feature called _Moments_ which are essentially AI-generated albums. I don't want AI to curate my data. Positioning themselves as an "AI-powered" application doesn't inspire confidence in me.
- [LibrePhotos](https://github.com/LibrePhotos/librephotos): While the user interface of LibrePhotos didn't appeal to me, the apparent lack of a dedicated mobile app that could automatically upload photos I've taken was a dealbreaker for me.
- [Photoview](https://github.com/photoview/photoview): This option feels like a version of Immich with less features, less development activity, and a smaller community. I tend to prefer using tools that have a wide base of support from developers and users, so I didn't pick this option despite it having most of the features I would like to have. It also doesn't appear to have a dedicated mobile app that could automatically upload photos I've taken.
- [NextCloud Photos](https://github.com/nextcloud/photos/): NextCloud has an official photos app which you can install through NextCloud's App management. It can also get automatic face detection through the installation of another NextCloud App. However, it lacks many organizational features and I don't really like how bloated NextCloud's ecosystem feels (something that I'll talk about more in a minute).

I also found this great [photo library comparison chart](https://meichthys.github.io/foss_photo_libraries/) compiled by GitHub user meichthys, which assisted me in evaluating which option was the right choice for me.

# Files

**[SyncThing](https://syncthing.net/)** is an open-source tool for continuously synchronizing files between different computers. I am currently storing all of my files with Dropbox, which is quite expensive and limited.

**Dropbox has a low storage limit.** I have a lot of files (in particular, pictures, video, and audio) to store, and I need space in excess of 3 TB, which is the highest storage tier available for a single user. The next-highest tier gives you 5 TB, but it also requires a minimum of three users, which costs \$15/user/month. This would cost me \$45/mo or \$540/year.

This appears to be an excessive price to me; a single 6TB Seagate IronWolf Pro internal HDD only costs \$132 on Amazon or \$0.022/GB at the time of this writing. Even if I had to buy a new HDD every year, this is orders of magnitude cheaper than Dropbox's \$0.108/GB price. Even [Backblaze](https://www.backblaze.com/cloud-storage/pricing) is significantly cheaper than Dropbox, offering cloud storage for \$6/TB/mo (or approximately \$0.072/GB). I understand that there is an electricity cost that I'm not accounting for here. But, I have trouble believing that running a small NAS would increase my electricity bill by more than \$408 a year, the difference between the cost of a single 6TB hard drive and the yearly Dropbox cost.

The premium that Dropbox charges is probably due to the fact that Dropbox is targeting a business demographic which is interested in office productivity software. However, and I cannot stress this enough, _all I want to do is sync files between computers and make my files available to me when I am away from home_.

**Dropbox has a small history.** Dropbox only offers 180 days of history, but I would like to have a history of at least one year. I often don't notice issues in my files for a long time and having a longer backup window would be more useful for me.

**Dropbox is reading all of my files.** Dropbox is not E2EE and stores all of my files unencrypted. It makes me uncomfortable to know that if someone at Dropbox wanted to, they could look at my files. Especially considering how tech companies are more than happy to use user data for unsavory purposes like selling analytics and aggregate user data it to other companies or using it to train AI, I don't want to store files on Dropbox if I can help it.

SyncThing is a well-known tool that does just this with active development and an active community, it has an official desktop client and an official mobile client (although it was delisted from Google Play so you'll have to either install it manually or through F-Droid, see [syncthing/syncthing-android#2064](https://github.com/syncthing/syncthing-android/issues/2064)), and it does exactly what I want: sync files between my devices. I haven't used SyncThing extensively yet though, so my opinion on the tool may change.

Alternatives include:
- [NextCloud](https://nextcloud.com/): This open-source cloud file server is similar to Dropbox, also sporting office productivity features as well as a way to install "apps" which extend the functionality of the NextCloud platform to do things like organize your photos and play music. The office productivity software is utterly unappealing to me and makes the platform too bloated for my tastes. Additionally, much of the time the Nextcloud apps pale in comparison to software projects dedicated to doing one specific thing (like Immich for example). I already have good programs on my computer or phone that I want to use with my files and the NextCloud apps, aside from the extremely limiting requirement that they are dependent on the NextCloud ecosystem to work, simply cannot compare. If all of that wasn't enough, even as a technically-savvy user, NextCloud is in my opinion very complicated to install and maintain.
- [Seafile](https://www.seafile.com): Seafile is another file syncing platform which concerns itself with becoming a document collaboration platform. Although open-source, it is also not entirely free and some features are only available with the professional edition of the application which costs money if you have more than 3 users. The lack of distinction from NextCloud and the relatively smaller size of this community compared to NextCloud and SyncThing made me feel like I would be better off not picking this one.

Notably, backup tools like [BorgBackup](https://www.borgbackup.org/) and [Restic](https://restic.net/) do **not** count as alternatives because they do not support multiple clients. In other words, you can have multiple backup locations but you can have more than one computer using the same backup location.

Similarly, tools like [rsync](https://github.com/RsyncProject/rsync) don't count as alternatives either, because they don't automatically synchronize files when they change.

# Other

There are also other things that I want to do:

- **Gitea**: I can self-host my own private repositories now! Well, I was already doing this with a VPS to collaborate with others on my games, but it's expensive! In particular, I want to start using Git to version my FL Studio music projects, which would involve using Git LFS a lot.
- **Peertube**: I'd like to investigate the possibility of hosting my VODs on my own hardware. VODs take up a lot of space, but not that many people watch VODs either. I currently use Vimeo to do this, and it costs me \$240 plus tax. I think self-hosting is probably cheaper at this rate, especially considering the relatively low expected bandwidth usage.
- **WoL Device**: It would be really cool to set up a low-power always-on device which I can use to power on computers in my VPN remotely using the Wake-on-Lan feature than many motherboards support. This would help in situations where my computers go down for some reason (or I accidentally shutdown the computer) and I'm away from home for an extended period of time. I'm planning on installing `etherwake` on a second-hand Raspberry Pi from a friend to do this (I don't really want to buy a new one because I don't want to support Raspberry Pi after they decided to hire a cop who used Raspberry Pis to build covert surveillance devices and especially due to how they reacted to the community which disagreed with this hire, see [this PetaPixel article](https://petapixel.com/2022/12/09/raspberry-pi-under-fire-by-creators-who-are-upset-it-hired-a-former-cop/))
- **Learn Nix and NixOS finally**: Wow, it would be really nice if I could have a reproducible way to set up all of these services I want to self-host...

# colophon

Posted at:
- [cohost!](https://cohost.org/exodrifter/post/7283616-self-hosting-is-exci) on 2024-08-13 at 20:22 UTC
