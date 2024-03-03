
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьС_MOEX(Команда)
	ЗагрузитьС_MOEXНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьС_MOEXНаСервере()
//	URL = СтрШаблон(
//			"%1/%2.json?%3",
//			"https://iss.moex.com/iss/securities",
//			"RU000A100WA8", 
////			Объект.SECID,
//			"iss.meta=off&iss.only=description"
////			"iss.meta=off&iss.only=description&iss.json=extended"
//		);
//	Результат = КоннекторHTTP.GetJson(URL);

//	Сообщить(Результат);
КонецПроцедуры

#КонецОбласти
