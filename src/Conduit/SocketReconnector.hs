module Conduit.SocketReconnector
  (
    runGeneralTCPReconnectClient
  )
where

import           RIO

import           Data.Conduit.Network

import           System.IO.Error



runGeneralTCPReconnectClient
  :: (MonadUnliftIO m, MonadReader env m, HasLogFunc env)
  => ClientSettings
  -> Int
  -> (AppData -> m a)
  -> m ()
  -> m a
runGeneralTCPReconnectClient csettings delay f onDisconnect = do
  (term, result) <- catch
    worker
    (\(_ :: IOError) -> return (False, undefined)
    )
  if term
    then return result
    else do
      threadDelay delay
      runGeneralTCPReconnectClient csettings delay f onDisconnect
  where 
    worker = do
        res <- runGeneralTCPClient csettings f
        onDisconnect
        pure (False, res)

