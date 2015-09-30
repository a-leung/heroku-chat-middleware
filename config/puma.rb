preload_app!

on_worker_boot do
  ClientManager.initialize
end
