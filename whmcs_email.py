from selenium import webdriver
import time

browser = webdriver.Chrome('/home/l6y/chromedriver');
url = 'URL/clients/admin/login.php?redirect=%2Fclients%2Fadmin%2F'
search_url = 'URL/clients/admin/index.php?rp=/admin/domains&domain='
username = 'USERNAME'
password = 'PASSWORD'

browser.get(url)
time.sleep(5)
name_usr = "username"
name_pswd = "password"
search_usr = browser.find_element_by_name(name_usr)
search_pswd = browser.find_element_by_name(name_pswd)
username_field = search_usr
password_field = search_pswd

print(search_usr)
print(search_pswd)

password_field.send_keys(password)
username_field.send_keys(username)


submit_login = browser.find_element_by_css_selector("input[type='submit']")
submit_login.click()

time.sleep(2)


with open('domains', 'r') as domains:
    for thedomain in domains:

        browser.get(url)

        time.sleep(2)

        # поиск в левом меню
        ## find domain's search
        browser.get(f"{search_url}{thedomain}")

        time.sleep(5)

        # клик на домен

        xpath_domain = f"//a[contains(text(), {thedomain})]"
        get_domain = browser.find_element_by_xpath("/html/body/div[@id='content_container']/div[@class='col-md-10 col-md-push-2 col-sm-9 col-sm-push-3']/div[@id='content']/div[@id='content_padded']/form[2]/div[@class='tablebg']/table[@id='sortabletbl0']/tbody/tr[2]/td[3]/a[1]")
        get_domain.click()

        time.sleep(5)

        get_message = browser.find_element_by_xpath("//select[@name='messageID']/option[17]")
        get_message.click()

        send_message = browser.find_element_by_xpath("//div[@class='contentbox']/input[@class='btn btn-default btn-sm']")
        send_message.click()
browser.close()
print ('Рассылка в WHMCS выполнена успешно.')
