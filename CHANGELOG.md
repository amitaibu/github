Changes for 0.14.3

- Add `Hashable Auth` instance

Changes for 0.14.2

- Add `mkUserId`, `mkUserName`, `fromUserId`, `fromOrganizationId`

Changes for 0.14.1

- Add `membersOfWithR`, `listTeamMembersR`
- Add related enums: `OrgMemberFilter`, `OrgMemberRole`, `TeamMemberRole`
- Add `Enum` and `Bounded` instances to `Privacy`, `Permission`,
  `RepoPublicity`
- Don't require network access for search tests

Changes for 0.14.0

Large API changes:

- Use `Text` and `Vector` in place of `String` and `[]`.
- Use `Name` and `Id` tagged types for names and identifiers.
- Make detailed structures un-prefixed, simple ones prefixed with `Simple`. Example: `Team` and `SimpleTeam`.
- Decouple request creation from execution (`*R` and `executeRequest*` functions).
- Add `Binary` instances for all data
- `GithubOwner` is a `newtype` of `Either User Organization`. There's still `SimpleOwner`.

Changes for 0.5.0:

* OAuth.
* New function: `Github.Repos.organizationRepo`, to get the repo for a specific organization.
* Introduce a new `newRepoAutoInit` flag to `NewRepo`, for whether to initialize a repo while creating it.
* Relax the attoparsec version requirements.
* The above by [John Wiegley](https://github.com/jwiegley).

Changes for 0.4.1:

* Stop using the uri package.
* Use aeson version 0.6.1.0.
* Use attoparsec version 0.10.3.0.
* Use http-conduit over 1.8.
* Use unordered-containers between 0.2 and 0.3.

Changes for 0.4.0:

* Use http-conduit version 1.4.1.10.

Changes for 0.3.0:

* Re-instantiate the Blobs API.
* `repoDescription1` and `repoPushedAt` are a `Maybe GithubDate`.
* Add `deleteRepo`, `editRepo`, and `createRepo`.
* Private gists, issues, organizations, pull requests, and users.
* Lock down `tls` and `tls-extra` instead of keeping up with the
  ever-changing `http-conduit` package.
* Features by [Pavel Ryzhov](https://github.com/paulrzcz) and [Simon Hengel](https://github.com/sol).

Changes for 0.2.1:

* Expand the unordered-containers dependency to anything in 0.1.x .

Changes for 0.2.0:

* `milestoneDueOn` and `repoLanguage` are now `Maybe` types.
* Introduce `GithubOwner` as the sum type for a `GithubUser` or `GithubOrganization`. Everything that once produced a `GithubUser` now produces a `GithubOwner`. All record accessors have changed their names
* Similar to `GithubOwner`, introduce `DetailedOwner`, which can be a `DetailedUser` or a `DetailedOrganization`. All record accessors have changed their names
* An `HTTPConnectionError` now composes `SomeException` instead of `IOException`. All exceptions raised by the underlying http-conduit library are encapulated there.
* The `githubIssueClosedBy` function now produces a `Maybe GithubOwner`.
* Remove the Blobs API, as it is broken upstream.
* Bugs found and squashed thanks to [Joey Hess](https://github.com/joeyh) and [Simon Hengel](https://github.com/sol).
