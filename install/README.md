# Installation Via Copy

This dibspack does an *installation* process by copying stuff from a source
to a destination. Files can be pruned from the source by means of
`.dibsignore` files, whose way of work is (hopefully) exactly the same as
`.gitignore` files for `git`.

# Copyright Acknowledgement For Included Modules

This program uses the following modules:

- [Path::Tiny][pt] by David Golden, licensed under The Apache License,
  Version 2.0, January 2004 (see link for details on the module). Module
  version included is `0.106`.
- [Text::Gitignore][tg] by Вячеслав Тихановский, licensed under the same
  terms as Perl itself. Module version included is `0.01` with a patch as
  of [this GitHub Pull Request][ghpr].

[pt]: https://metacpan.org/pod/Path::Tiny
[tg]: https://metacpan.org/pod/Text::Gitignore
[ghpr]: https://github.com/vti/text-gitignore/pull/1
