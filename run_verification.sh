#обработка копипаста из каяки

cat emails_raw | egrep 'failed, domain|Верификация адреса' | awk -F ' ' '{print $6}' > emails

emails_amount=$(cat emails | wc -l)

# Основной цикл по которому хендлится каждый email

cat emails | while read email
do

	### Получаю токен аутентификации в OP, т.к. он живёт 48 часов или шото такое, получаю каждый раз новый

	echo " "
	echo "====================================="
	echo ' '
	curl -s -X POST https://api.openprovider.eu/v1beta/auth/login \
	 -d '{"username": "USERNAME", "password": "PASSWORD", "ip": "IP"}' > auth_token_json
	cat auth_token_json | jq -r '. | .data.token' > auth_token

	cat auth_token #Вывожу токен в терминале, чтобы убедиться что всё ок

	auth_token=$(cat auth_token)


	## Получаю все домены, которыми обладает пользователь с конкретным email: https://docs.openprovider.com/doc/all#tag/EmailVerification 
	curl -s -X GET 'https://api.openprovider.eu/v1beta/customers/verifications/emails/domains/' \
		-H 'Authorization: Bearer '$auth_token'' \
		-Gd 'email='$email'' > domains_raw

	cat domains_raw | jq -r '. | .data.results[].domain' > domains
	cat domains > domains_"${email}"
	cat domains


	######################################### нужно добавить проверку тега по кастомеру и отправку уведомление от корректного прожекта


	##Переотправляю проверочный email

	curl -X POST -H 'Authorization: Bearer '$auth_token'' -H "Content-Type: application/json" -d '{"email": "'$email'"}' https://api.openprovider.eu/v1beta/customers/verifications/emails/restart

	echo ' '
	echo '[] Запуск уведомлений со стороны WHMCS'
	echo ' '
	python3 whmcs_email.py
	######################################### нужно добавить проверку успешного уведомления 

	echo -e '\e[32m[OK]\e[0m Уведомления в WHMCS'
	rm -f auth_token auth_token_json domains domains_raw 2>/dev/null
done


##########Вывод общей инфы по итогу работы 
cat /dev/null > emails_raw
echo ' '
echo Данные пользователи были уведомлены: 
echo ' '

cat emails | while read email
do	
	cat domains_${email} | while read domain
	do
		echo -e "\e[1mEmail\e[21m: $email \e[1mDomain\e[21m: $domain"
	done
done

## Подчищаю временные файлы
rm emails 2>/dev/null
rm domains_*
cat /dev/null > emails_raw

## Уведомляю сам себя
google-chrome-stable 'https://miro.medium.com/max/3840/1*S89gBM63qM-_kQ6wVHtBzw.png'
