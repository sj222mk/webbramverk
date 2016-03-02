## Detta är en webbapplikation utvecklad i kursen 1DV450 på Linnéuniversitet.##
* Applikationen är skriven i [Cloud 9](http://www.c9.io). En körbar version finns på [Heroku](https://webbramverk.herokuapp.com/).
* I applikationen kan man skapa en användare. 
    * Som inloggad användare kan man redigera sina användaruppgifter samt skapa api-nycklar.
* Till applikationen finns en admin-inloggning.
    * Som admin kan man, förutom det en användare kan, även ta bort användare samt enskilda användares nycklar.
    * Önskas inloggningsuppgifter till admin-kontot: kontakta mig på min skolmailadress.

###För att få igång applikationen i utvecklingsmiljö###
* Gör en fork av repot på GitHub
* Logga in på [Cloud 9](http://www.c9.io). (Om man inte har konto är det gratis att skapa)
* Gå till Repositories på din dashboard.
* Tryck "Clone to edit" på repot du nyss forkade på GitHub. (Är du ny på Cloud 9 får du först ansluta till ditt GitHub-konto)
* Döp applikationen och välj "Rails tutorial" under templates.
* Installera gems: Skriv "bundle install" i console-fönstret.
* Migrera (skapa) databas: Skriv "bundle exec rake db:migrate" i console-fönstret.
* För att köra applikationen/starta rails server: Skriv "rails server -b $IP -p $PORT" i ett nytt console-fönster.
* För att se applikationen tryck på Preview...

###Användbara kommandon i consolen###
(använd det första console-fönstret, inte det där servern går)
* Kolla routes: bundle exec rake routes
* Fylla databasen med seeds: bundle exec rake db:seed
* Ta bort databasen: bundle exec rake db:migrate:reset
* Migrera databas: bundle exec rake db:migrate

###Testning###
(lämpligt att köra i ett eget/nytt console-fönster)
* Köra test:  bundle exec rake test
* Testa hela tiden i bakgrunden: bundle exec guard (Körs automatiskt när man ändrar något i koden. Man kan även trycka enter för att köra alla tester.)

