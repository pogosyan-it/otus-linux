# **Руководство по созданию VirtualBox Shared Folder**

1. Установить последнюю версию Virtual Box `(6.1.6)`
2. Установить соответстующую версию Virtual box Extantion Pack
3. Установить последнюю версию Vagrant `(2.2.7)`
4. Добавить в vagrantfile строки:
   **config.vm.synced_folder "../path/to/shared/folder_on_host/", "/shared_folder_on_guest/"**
   - где первый аргумент это относительный путь к папке в host системе, а второй - путь в guest системе
5. В host системе запустить 2 команды:
   `vagrant plugin install vagrant-vbguest`
   `vagrant vbguest`

После запуска вм `(vagrant up)` shara заработает.
