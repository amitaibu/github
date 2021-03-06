module Common (
    -- * Common stuff
    getAuth,
    tshow,
    -- * Re-exports
    (<>),
    fromString,
    Text,
    putStrLn,
    getArgs,
    Proxy(..),
    module Prelude.Compat,
    ) where

import Prelude        ()
import Prelude.Compat hiding (putStrLn)

import Data.Monoid        ((<>))
import Data.Proxy         (Proxy (..))
import Data.String        (fromString)
import Data.String        (fromString)
import Data.Text          (Text)
import Data.Text.IO       (putStrLn)
import System.Environment (lookupEnv)
import System.Environment (getArgs)

import qualified Data.Text as T
import qualified GitHub

getAuth :: IO (Maybe (GitHub.Auth))
getAuth = do
    token <- lookupEnv "GITHUB_TOKEN"
    pure (GitHub.OAuth . fromString <$> token)

tshow :: Show a => a -> Text
tshow = T.pack . show
