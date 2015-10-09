preload_app!

workers 1
threads 32, 32

on_worker_boot do
  ClientManager.initialize
end
