{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE OverloadedStrings  #-}
-----------------------------------------------------------------------------
-- |
-- License     :  BSD-3-Clause
-- Maintainer  :  Oleg Grenrus <oleg.grenrus@iki.fi>
--
-- The Github Repos API, as documented at
-- <http://developer.github.com/v3/repos/>
module GitHub.Endpoints.Repos (
    -- * Querying repositories
    currentUserRepos,
    currentUserReposR,
    userRepos,
    userRepos',
    userReposR,
    organizationRepos,
    organizationRepos',
    organizationReposR,
    repository,
    repository',
    repositoryR,
    contributors,
    contributors',
    contributorsR,
    contributorsWithAnonymous,
    contributorsWithAnonymous',
    languagesFor,
    languagesFor',
    languagesForR,
    tagsFor,
    tagsFor',
    tagsForR,
    branchesFor,
    branchesFor',
    branchesForR,
    contentsFor,
    contentsFor',
    readmeFor,
    readmeFor',

    -- ** Create
    createRepo',
    createRepoR,
    createOrganizationRepo',
    createOrganizationRepoR,

    -- ** Edit
    editRepo,
    editRepoR,

    -- ** Delete
    deleteRepo,
    deleteRepoR,

    -- * Data
    module GitHub.Data,
    ) where

import Prelude        ()
import Prelude.Compat

import Control.Applicative ((<|>))
import Data.Aeson.Compat   (encode)
import Data.Vector         (Vector)

import GitHub.Data
import GitHub.Request

import qualified Data.ByteString.Char8 as BS8

repoPublicityQueryString :: RepoPublicity -> QueryString
repoPublicityQueryString RepoPublicityAll     = [("type", Just "all")]
repoPublicityQueryString RepoPublicityOwner   = [("type", Just "owner")]
repoPublicityQueryString RepoPublicityMember  = [("type", Just "member")]
repoPublicityQueryString RepoPublicityPublic  = [("type", Just "public")]
repoPublicityQueryString RepoPublicityPrivate = [("type", Just "private")]

-- | List your repositories.
currentUserRepos :: Auth -> RepoPublicity -> IO (Either Error (Vector Repo))
currentUserRepos auth publicity =
    executeRequest auth $ currentUserReposR publicity Nothing

-- | List your repositories.
-- See <https://developer.github.com/v3/repos/#list-your-repositories>
currentUserReposR :: RepoPublicity -> Maybe Count -> Request k(Vector Repo)
currentUserReposR publicity =
    PagedQuery  ["user", "repos"] qs
  where
    qs = repoPublicityQueryString publicity

-- | The repos for a user, by their login. Can be restricted to just repos they
-- own, are a member of, or publicize. Private repos will return empty list.
--
-- > userRepos "mike-burns" All
userRepos :: Name Owner -> RepoPublicity -> IO (Either Error (Vector Repo))
userRepos = userRepos' Nothing

-- | The repos for a user, by their login.
-- With authentication.
--
-- > userRepos' (Just (BasicAuth (user, password))) "mike-burns" All
userRepos' :: Maybe Auth -> Name Owner -> RepoPublicity -> IO (Either Error (Vector Repo))
userRepos' auth user publicity =
    executeRequestMaybe auth $ userReposR user publicity Nothing

-- | List user repositories.
-- See <https://developer.github.com/v3/repos/#list-user-repositories>
userReposR :: Name Owner -> RepoPublicity -> Maybe Count -> Request k(Vector Repo)
userReposR user publicity =
    PagedQuery  ["users", toPathPart user, "repos"] qs
  where
    qs = repoPublicityQueryString publicity

-- | The repos for an organization, by the organization name.
--
-- > organizationRepos "thoughtbot"
organizationRepos :: Name Organization -> IO (Either Error (Vector Repo))
organizationRepos org = organizationRepos' Nothing org RepoPublicityAll

-- | The repos for an organization, by the organization name.
-- With authentication.
--
-- > organizationRepos (Just (BasicAuth (user, password))) "thoughtbot" All
organizationRepos' :: Maybe Auth -> Name Organization -> RepoPublicity -> IO (Either Error (Vector Repo))
organizationRepos' auth org publicity =
    executeRequestMaybe auth $ organizationReposR org publicity Nothing

-- | List organization repositories.
-- See <https://developer.github.com/v3/repos/#list-organization-repositories>
organizationReposR :: Name Organization -> RepoPublicity -> Maybe Count -> Request k (Vector Repo)
organizationReposR org publicity =
    PagedQuery ["orgs", toPathPart org, "repos"] qs
  where
    qs = repoPublicityQueryString publicity

-- | Details on a specific repo, given the owner and repo name.
--
-- > userRepo "mike-burns" "github"
repository :: Name Owner -> Name Repo -> IO (Either Error Repo)
repository = repository' Nothing

-- | Details on a specific repo, given the owner and repo name.
-- With authentication.
--
-- > userRepo' (Just (BasicAuth (user, password))) "mike-burns" "github"
repository' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error Repo)
repository' auth user repo =
    executeRequestMaybe auth $ repositoryR user repo

-- | Query single repository.
-- See <https://developer.github.com/v3/repos/#get>
repositoryR :: Name Owner -> Name Repo -> Request k Repo
repositoryR user repo =
    Query ["repos", toPathPart user, toPathPart repo] []

-- | Create a new repository.
--
-- > createRepo' (BasicAuth (user, password)) (newRepo "some_repo") {newRepoHasIssues = Just False}
createRepo' :: Auth -> NewRepo -> IO (Either Error Repo)
createRepo' auth nrepo =
    executeRequest auth $ createRepoR nrepo

-- | Create a new repository.
-- See <https://developer.github.com/v3/repos/#create>
createRepoR :: NewRepo -> Request 'True Repo
createRepoR nrepo =
    Command Post ["user", "repos"] (encode nrepo)

-- | Create a new repository for an organization.
--
-- > createOrganizationRepo (BasicAuth (user, password)) "thoughtbot" (newRepo "some_repo") {newRepoHasIssues = Just False}
createOrganizationRepo' :: Auth -> Name Organization -> NewRepo -> IO (Either Error Repo)
createOrganizationRepo' auth org nrepo =
    executeRequest auth $ createOrganizationRepoR org nrepo

-- | Create a new repository for an organization.
-- See <https://developer.github.com/v3/repos/#create>
createOrganizationRepoR :: Name Organization -> NewRepo -> Request 'True Repo
createOrganizationRepoR org nrepo =
    Command Post ["orgs", toPathPart org, "repos"] (encode nrepo)

-- | Edit an existing repository.
--
-- > editRepo (BasicAuth (user, password)) "some_user" "some_repo" def {editDescription = Just "some description"}
editRepo :: Auth
         -> Name Owner      -- ^ owner
         -> Name Repo             -- ^ repository name
         -> EditRepo
         -> IO (Either Error Repo)
editRepo auth user repo body =
    executeRequest auth $ editRepoR user repo body


-- | Edit an existing repository.
-- See <https://developer.github.com/v3/repos/#edit>
editRepoR :: Name Owner -> Name Repo -> EditRepo -> Request 'True Repo
editRepoR user repo body =
    Command Patch ["repos", toPathPart user, toPathPart repo] (encode b)
  where
    -- if no name is given, use curent name
    b = body {editName = editName body <|> Just repo}

-- | The contributors to a repo, given the owner and repo name.
--
-- > contributors "thoughtbot" "paperclip"
contributors :: Name Owner -> Name Repo -> IO (Either Error (Vector Contributor))
contributors = contributors' Nothing

-- | The contributors to a repo, given the owner and repo name.
-- With authentication.
--
-- > contributors' (Just (BasicAuth (user, password))) "thoughtbot" "paperclip"
contributors' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error (Vector Contributor))
contributors' auth user repo =
    executeRequestMaybe auth $ contributorsR user repo False Nothing

-- | List contributors.
-- See <https://developer.github.com/v3/repos/#list-contributors>
contributorsR :: Name Owner
              -> Name Repo
              -> Bool              -- ^ Include anonymous
              -> Maybe Count
              -> Request k (Vector Contributor)
contributorsR user repo anon =
    PagedQuery ["repos", toPathPart user, toPathPart repo, "contributors"] qs
  where
    qs | anon      = [("anon", Just "true")]
       | otherwise = []

-- | The contributors to a repo, including anonymous contributors (such as
-- deleted users or git commits with unknown email addresses), given the owner
-- and repo name.
--
-- > contributorsWithAnonymous "thoughtbot" "paperclip"
contributorsWithAnonymous :: Name Owner -> Name Repo -> IO (Either Error (Vector Contributor))
contributorsWithAnonymous = contributorsWithAnonymous' Nothing

-- | The contributors to a repo, including anonymous contributors (such as
-- deleted users or git commits with unknown email addresses), given the owner
-- and repo name.
-- With authentication.
--
-- > contributorsWithAnonymous' (Just (BasicAuth (user, password))) "thoughtbot" "paperclip"
contributorsWithAnonymous' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error (Vector Contributor))
contributorsWithAnonymous' auth user repo =
    executeRequestMaybe auth $ contributorsR user repo True Nothing

-- | The programming languages used in a repo along with the number of
-- characters written in that language. Takes the repo owner and name.
--
-- > languagesFor "mike-burns" "ohlaunch"
languagesFor :: Name Owner -> Name Repo -> IO (Either Error Languages)
languagesFor = languagesFor' Nothing

-- | The programming languages used in a repo along with the number of
-- characters written in that language. Takes the repo owner and name.
-- With authentication.
--
-- > languagesFor' (Just (BasicAuth (user, password))) "mike-burns" "ohlaunch"
languagesFor' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error Languages)
languagesFor' auth user repo =
    executeRequestMaybe auth $ languagesForR user repo

-- | List languages.
-- See <https://developer.github.com/v3/repos/#list-languages>
languagesForR :: Name Owner -> Name Repo -> Request k Languages
languagesForR user repo =
    Query  ["repos", toPathPart user, toPathPart repo, "languages"] []

-- | The git tags on a repo, given the repo owner and name.
--
-- > tagsFor "thoughtbot" "paperclip"
tagsFor :: Name Owner -> Name Repo -> IO (Either Error (Vector Tag))
tagsFor = tagsFor' Nothing

-- | The git tags on a repo, given the repo owner and name.
-- With authentication.
--
-- > tagsFor' (Just (BasicAuth (user, password))) "thoughtbot" "paperclip"
tagsFor' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error (Vector Tag))
tagsFor' auth user repo =
    executeRequestMaybe auth $ tagsForR user repo Nothing

-- | List tags.
-- See <https://developer.github.com/v3/repos/#list-tags>
tagsForR :: Name Owner -> Name Repo -> Maybe Count -> Request k (Vector Tag)
tagsForR user repo =
    PagedQuery  ["repos", toPathPart user, toPathPart repo, "tags"] []

-- | The git branches on a repo, given the repo owner and name.
--
-- > branchesFor "thoughtbot" "paperclip"
branchesFor :: Name Owner -> Name Repo -> IO (Either Error (Vector Branch))
branchesFor = branchesFor' Nothing

-- | The git branches on a repo, given the repo owner and name.
-- With authentication.
--
-- > branchesFor' (Just (BasicAuth (user, password))) "thoughtbot" "paperclip"
branchesFor' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error (Vector Branch))
branchesFor' auth user repo =
    executeRequestMaybe auth $ branchesForR user repo Nothing

-- | List branches.
-- See <https://developer.github.com/v3/repos/#list-branches>
branchesForR :: Name Owner -> Name Repo -> Maybe Count -> Request k (Vector Branch)
branchesForR user repo =
    PagedQuery  ["repos", toPathPart user, toPathPart repo, "branches"] []

-- | The contents of a file or directory in a repo, given the repo owner, name, and path to the file
--
-- > contentsFor "thoughtbot" "paperclip" "README.md"
contentsFor :: Name Owner -> Name Repo -> String -> Maybe String -> IO (Either Error Content)
contentsFor = contentsFor' Nothing

-- | The contents of a file or directory in a repo, given the repo owner, name, and path to the file
-- With Authentication
--
-- > contentsFor' (Just (BasicAuth (user, password))) "thoughtbot" "paperclip" "README.md" Nothing
contentsFor' :: Maybe Auth ->  Name Owner -> Name Repo -> String -> Maybe String -> IO (Either Error Content)
contentsFor' auth user repo path ref =
    executeRequestMaybe auth $ contentsForR user repo path ref

contentsForR :: Name Owner
             -> Name Repo
             -> String            -- ^ file or directory
             -> Maybe String      -- ^ Git commit
             -> Request k Content
contentsForR user repo path ref =
    Query ["repos", toPathPart user, toPathPart repo, "contents", path] qs
  where
    qs =  maybe [] (\r -> [("ref", Just . BS8.pack $ r)]) ref

-- | The contents of a README file in a repo, given the repo owner and name
--
-- > readmeFor "thoughtbot" "paperclip"
readmeFor :: Name Owner -> Name Repo -> IO (Either Error Content)
readmeFor = readmeFor' Nothing

-- | The contents of a README file in a repo, given the repo owner and name
-- With Authentication
--
-- > readmeFor' (Just (BasicAuth (user, password))) "thoughtbot" "paperclip"
readmeFor' :: Maybe Auth -> Name Owner -> Name Repo -> IO (Either Error Content)
readmeFor' auth user repo =
    executeRequestMaybe auth $ readmeForR user repo

readmeForR :: Name Owner -> Name Repo -> Request k Content
readmeForR user repo =
    Query ["repos", toPathPart user, toPathPart repo, "readme"] []

-- | Delete an existing repository.
--
-- > deleteRepo (BasicAuth (user, password)) "thoughtbot" "some_repo"
deleteRepo :: Auth -> Name Owner -> Name Repo -> IO (Either Error ())
deleteRepo auth user repo =
    executeRequest auth $ deleteRepoR user repo

deleteRepoR :: Name Owner -> Name Repo -> Request 'True ()
deleteRepoR user repo =
    Command Delete ["repos", toPathPart user, toPathPart repo] mempty
