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

# Налаштовуємо фаєрвол

Ідемо в Security Groups і відкриваємо групу default, яку надалі будемо використовувати у віртуальних машинах. Натискаємо кнопку `Edit inbound rules`:

![Inbound rules dashboard](ec2-rules_pre.png)

Відкриваємо порти 22 і 80 і нвтискаємо кнопку `Save rules`

![Inbound rules set](ec2-rules_ready.png)

Мережеві порти успішно налаштовано. В ідеалі, можна було б обмежити доступ до порту 22 лише для конкретної ip-адреси, але залишимо доступ для всіх

![Inbound rules success](ec2-rules_success.png)

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

Обираємо раніше створений нами ssh-ключ:

![Обираємо ssh-ключ для EC2](ec2-choose_key.png)

Встановлюємо security group для EC2 - обираємо default для спрощення роботи:

![Обираємо security group для EC2](ec2-choose_security_group.png)

Розгортаємо блок `Advanced details` і гортаємо в кінець, до поля `User data`. Заповнюємо його вмістом скрипта, який встановить, налаштує і увімкне nginx:

```bash
#!/bin/bash
sudo su
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
curl -s https://phrippy-task30.s3.eu-central-1.amazonaws.com/1.txt > /var/www/html/index.html
```

Налаштування EC2 завершено, натискаємо кнопку `Launch instance`:

![Створюємо EC2](ec2-fill_userdata.png)

Чекаємо, поки EC2 не набуде статусу `Running` і відкриваємо сторінку з деталями:

![Інформація про EC2](ec2-info.png)

Як бачимо, віртуальна машина має публічні IP та DNS-імʼя. Спробуємо відкрити IP в браузері:

![Відриття IP EC2 в браузері](ec2-ip.png)

Схоже, все працює. Створимо ще одно віртуальну машину EC2, але тепер скопіюємо інший файл як основну сторінку для nginx:

```bash
#!/bin/bash
sudo su
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
curl -s https://phrippy-task30.s3.eu-central-1.amazonaws.com/2.txt > /var/www/html/index.html
```

# Створюємо Load Balancer

Відкриваємо сторінку Load Balancer і натискаємо кнопку `Create Load Balancer`:

![Load Balancer Dashboard](lb-button.png)

Обираємо `Classic Load Balancer` і натискаємо `Create`:

![Вибір Load Balancer-а](lb-classic.png)

Тут просто обираємо імʼя для балансера і натискаємо Next:

![Вибір Load Balancer-а](lb-define.png)

Тут обираємо вже існуючу групу Default:

![Вибір Security Group для Load Balancer-а](lb-sg.png)

Це попередження можна проігнорувати, оскільки в нас тестовий стенд і трафік без шифрування по протоколу HTTP. В реальних умовах, звісно ж, потрібно налаштувати HTTPS-доступ

![Вибір Security Group для Load Balancer-а](lb-ssl.png)

Параметри healthcheck залишаємо за замовчуванням, тут вони повністю підходять:

![Load Balancer Healthcheck](lb-healthcheck.png)

Обираємо наші дві віртуальні машини EC2 і додаємо їх в Load Balancer:

![Load Balancer EC2](lb-ec2.png)

На даному етапі теги нас не цікавлять, тому просто натискаємо `Review and Create`:

![Load Balancer EC2](lb-tags.png)

Перевіряємо, чи все правильно і тиснемо `Create`:

![Load Balancer EC2](lb-create.png)

Відкриваємо вкладку `Instances` і пересвідчуємося, що обидві віртуальні машини перебувають в статусі `InService`:

![Load Balancer Dashboard](lb-dashboard.png)

В стовпці `DNS name` знаходиться DNS-імʼя Load Balancer-а. Звісно, можна відкрити DNS-імʼя `myloadbalancer-1211606296.eu-central-1.elb.amazonaws.com` в браузері, але це скріншот не покаже його інтерактивної роботи. Тому для наглядності напишемо простенький скрипт:

```bash
#!/bin/bash
URL='myloadbalancer-1211606296.eu-central-1.elb.amazonaws.com'
for i in {1..9} ; do
    echo "Attempt $i: $(curl -s ${URL})"
		sleep 1
done
```
