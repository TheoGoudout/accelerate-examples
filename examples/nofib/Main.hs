{-# LANGUAGE CPP #-}
module Main where

import Test.Framework
import Control.Exception
import System.Exit
import System.Environment

import Config
import Monitoring
import Test.IO
import Test.Prelude
import Test.Sharing
import Test.Imaginary
import Test.Spectral
#ifdef ACCELERATE_CUDA_BACKEND
import Test.Foreign
#endif


main :: IO ()
main = do

  -- Kick off EKG monitoring. Perhaps not particularly useful since we spend a
  -- lot of time just generating random data, etc.
  --
  beginMonitoring

  -- process command line args, and print a brief usage message
  --
  argv                          <- getArgs
  (conf, cconf, tfconf, nops)   <- parseArgs' configHelp configBackend options defaults header footer argv

  -- Run tests, executing the simplest first. More complex operations, such as
  -- segmented operations, generally depend on simpler tests. We build up to the
  -- larger test programs.
  --
  defaultMainWithOpts
    [ test_prelude conf
    , test_sharing conf
    , test_io conf
    , test_imaginary conf
    , test_spectral conf
#ifdef ACCELERATE_CUDA_BACKEND
    , test_foreign conf
#endif
    ]
    tfconf
    -- test-framework wants to have a nap on success; don't let it.
    `catch` \e -> case e of
                    ExitSuccess -> return()
                    _           -> throwIO e

  -- Now run some criterion benchmarks.
  --
  -- TODO: We should dump the results to file so that they can be analysed and
  --       checked for regressions.
  --

