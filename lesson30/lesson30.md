* зарегистрироваться в AWS Cloud. создать IAM пользователя.

* установить AWS cli, авторизовать его.

* создать 2 ЕС2, настроить к ним доступ через load balancer.

* создать две статических html страницы (например выводящих "1" и "2") для проверки работы лоад балансера.

* статические страницы разместить в S3. настроить хттп доступ к ним.

* настроить установку веб серверва и копирование статических страниц в ЕС2 при помощи user data. на двух виртуалках должны быть разные хтмл страницы (отчет - вывод разлиных страниц при обращении к ЕС2 через лоад балансер).

# Встановлюємо AWS cli

Спробуємо встановити AWS cli. Для цього скористаємося пакетним менеджером:

![Спроба запуску AWS cli](aws-cli_install.png)

Як бачимо, встановлення успішно завершено:

![AWS cli успішно встановлено](aws-cli_version.png)

Налаштуємо AWS cli, для цього запустимо команду `aws configure`

![AWS cli успішно встановлено](aws-cli_version.png)

Як бачимо, було створено файли `~/.aws/config` і `~/.aws/credentials` 

# Створюємо S3

Знаходимо через пошук розділ `S3` і натискаємо кнопку `Create S3 bucket`. Вводимо унікальний Bucket name, вмикаємо ACLs:

![Створення S3 bucket](s3-create.png)

Гортаємо вниз і знімаємо прапорець `Block all public access`. Ставимо прапорець `I acknowledge that the current settings might result in this bucket and the objects within becoming public.` Це потрібно для надання публічого доступу до наших даних

![Налаштування публічного доступу до S3 bucket](s3-public.png)

Всі інші опції залишаємо за замовчуванням. Натискаємо `Create bucket`:

![Створюємо S3 bucket](s3-create-finish.png)

S3 bucket успішно створено:

![S3 bucket успішно створено](s3-created.png)

# Створюємо файли, які будуть надалі зберігатися в S3

Для цього скористаємось магією bash. Створимо файл 1.txt із вмістом `1` і 2.txt із вмістом `2`:

```bash
for i in 1 2 ; do echo -n $i > $i.txt ; done
```
# Завантажуємо файли в S3

Заходимо в наш новостворений S3 і натискаємо кнопку `Upload`:

![Початок завантаження файлів в S3 bucket](s3-pre-upload.png)

Натискаємо кнопку `Add files` і завантажуємо файли 1.txt і 2.txt через стандартний інтерфейс браузера:

![Вибір файлів для завантаження в S3 bucket](s3-add_files.png)

Розгортаємо блок `Permissions` і ставимо перемикач `Predefined ACLs` в положення `Grant public-read access`. Піднімаємо прапорець `I understand the risk of granting public-read access to the specified objects.`

![Налаштування публічного доступу для файлів в S3 bucket](s3-upload_set_permissions.png)

Файли готові для завантаження в S3 bucket. Натискаємо кнопку `Upload`:

![Файли готові для завантаження в S3 bucket](s3-upload_ready.png)

Як бачимо, файли успішно завантажено:

![Файли успішно завантажено в S3 bucket](s3-upload_success.png)

# Дістаємо посилання на файли

Відкриваємо наші файли в S3 bucket і зберігаємо Object URL:

![Копіювання Object URL для файлу](s3-copy_object_url.png)

Ми отримали два посилання:

* https://phrippy-task30.s3.eu-central-1.amazonaws.com/1.txt
* https://phrippy-task30.s3.eu-central-1.amazonaws.com/2.txt

Вони знадобляться нам для налаштування веб-серверів nginx

# Створюємо EC2

Заходимо в EC2 Dashboard:

![EC2 Dashboard](ec2-dashboard.png)

Для початку створимо пару ssh-ключів. Заходимо в `Key pairs` і натискаємо `Create key pair` або `Actions -> Import key pair`, в залежності від потреби. Для простоти я імпортую свій ключ із локальної машини, але в ідеалі треба створити новий:

![EC2 Keypairs Dashboard](ec2-keypairs_dashboard.png)

Імпортуємо ключ з локальної машини (вивід команди `cat ~/.ssh/id_rsa.pub`):

![EC2 Import local ssh-key](ec2-keypairs_import_localkey.png)

Ключ успішно імпортовано:

![EC2 Import local ssh-key success](ec2-keypairs_import_success.png)

Тепер прийшла пора створити віртуальну машину, вона ж EC2. Натискаємо кнопку `Launch instance` в EC2 Dashboard.

Вводимо імʼя, наприклад `server1`:

![Вводимо імʼя для EC2](ec2-name.png)

# Створюємо EC2, в кінці вікна для налаштування вписуємо userdata, записуємо посилання із попереднього кроку в /var/www/html/index.html

# Створюємо Load Balancer

