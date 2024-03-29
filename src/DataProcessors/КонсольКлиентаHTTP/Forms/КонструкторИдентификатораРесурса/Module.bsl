
#Область ОбработчикиСобытийФормы
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОписаниеТипаЧисло = Новый ОписаниеТипов("Число");
	
	ИдентификаторРесурса = Параметры.ИдентификаторРесурса;
	
	ЗащищенноеСоединение = СтрНачинаетсяС(ИдентификаторРесурса, "https://");
	Если ЗащищенноеСоединение Тогда
		Элементы.ДекорацияСхема.Заголовок = "https://";
		Элементы.ДекорацияСхемаМП.Заголовок = "https://";
	КонецЕсли;
	
	ИдентификаторРесурса = СтрЗаменить(ИдентификаторРесурса, "https://", "");
	ИдентификаторРесурса = СтрЗаменить(ИдентификаторРесурса, "http://", "");
	ПозицияСимволаПараметров = СтрНайти(ИдентификаторРесурса, "?");
	ПозицияСимволаФрагмента = СтрНайти(ИдентификаторРесурса, "#", , ?(ПозицияСимволаПараметров = 0, 1, ПозицияСимволаПараметров));
	Если ПозицияСимволаФрагмента > 0 Тогда
		Фрагмент = Сред(ИдентификаторРесурса, ПозицияСимволаФрагмента + 1);
	КонецЕсли;
	ПозицияОкончания = ?(ПозицияСимволаПараметров = 0, ПозицияСимволаФрагмента, ПозицияСимволаПараметров) - 1;
	Если ПозицияОкончания > 0 Тогда
		ИдентификаторРесурса = Лев(ИдентификаторРесурса, ПозицияОкончания);
	КонецЕсли;
	ПозицияОкончания = СтрДлина(ИдентификаторРесурса);
	
	ПозицияПослеАвторизации = СтрНайти(ИдентификаторРесурса, "@");
	Если ПозицияПослеАвторизации > 0 И ПозицияПослеАвторизации < ПозицияОкончания Тогда
		Авторизация = Лев(ИдентификаторРесурса, ПозицияПослеАвторизации - 1);
		ДлинаАвторизации = СтрДлина(Авторизация);
		ПозицияРазделителяАвторизации = СтрНайти(Авторизация, ":");
		Если ПозицияРазделителяАвторизации = 0 Тогда
			ПозицияРазделителяАвторизации = ДлинаАвторизации + 1;
		КонецЕсли;
		
		ЗакодированныйПользователь = СокрЛП(Лев(Авторизация, ПозицияРазделителяАвторизации - 1));
		ЗакодированныйПароль = Прав(Авторизация, ДлинаАвторизации - ПозицияРазделителяАвторизации);
		МножествоСтрок = Новый Соответствие;
		МножествоСтрок.Вставить(ЗакодированныйПользователь);
		МножествоСтрок.Вставить(ЗакодированныйПароль);
		
		МножествоСтрок = КлиентHTTP.РаскодированныеСтрокиURLвURL(МножествоСтрок);
		Пользователь = МножествоСтрок.Получить(ЗакодированныйПользователь);
		Пароль = МножествоСтрок.Получить(ЗакодированныйПароль);
		ИдентификаторРесурса = Сред(ИдентификаторРесурса, ПозицияПослеАвторизации + 1);
		ПозицияОкончания = СтрДлина(ИдентификаторРесурса);
	КонецЕсли;
	
	ПозицияАдресаРесурса = СтрНайти(ИдентификаторРесурса, "/");
	Если ПозицияАдресаРесурса > 0 Тогда
		АдресРесурса = Сред(ИдентификаторРесурса, ПозицияАдресаРесурса + 1, ПозицияОкончания - ПозицияАдресаРесурса + 1);
		ПозицияОкончания = ПозицияАдресаРесурса - 1;
	КонецЕсли;
	
	ПозицияПорта = СтрНайти(ИдентификаторРесурса, ":", НаправлениеПоиска.СКонца, ПозицияОкончания);
	Если ПозицияПорта > 0 Тогда
		Порт = ОписаниеТипаЧисло.ПривестиЗначение(Сред(ИдентификаторРесурса, ПозицияПорта + 1, ПозицияОкончания - ПозицияПорта));
		ПозицияОкончания = ПозицияПорта - 1;
	Иначе
		Порт = ?(ЗащищенноеСоединение, 443, 80);
	КонецЕсли;
	
	Сервер = Лев(ИдентификаторРесурса, ПозицияОкончания);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	URI = ИдентификаторРесурса();
	
#Если МобильныйКлиент ИЛИ МобильноеПриложениеКлиент Тогда
	Элементы.Основная.Видимость = Ложь;
	Элементы.ФормаОК.Видимость = Ложь;
	Элементы.ОсновнаяМП.Видимость = Истина;
#КонецЕсли
КонецПроцедуры
#КонецОбласти

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура ОК(Команда)
	Перем ПроверяемоеПоле;
	
#Если МобильныйКлиент ИЛИ МобильноеПриложениеКлиент Тогда
	ПроверяемоеПоле = "СерверМП";
#Иначе
	ПроверяемоеПоле = "Сервер";
#КонецЕсли
	
	Если ПустаяСтрока(Сервер) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Укажите имя хоста";
		Сообщение.Поле = ПроверяемоеПоле;
		Сообщение.Сообщить();
		
		Возврат;
	КонецЕсли;
	
	Закрыть(ИдентификаторРесурса() + ?(ПустаяСтрока(Фрагмент), "", "#" + Фрагмент));
КонецПроцедуры
#КонецОбласти

#Область ПЕРСОНАЛЬНЫЙ_КОМПЬЮТЕР
#Область ОбработчикиСобытийЭлементовШапкиФормы
&НаКлиенте
Процедура ЗащищенноеСоединениеПриИзменении(Элемент)
	ОформитьЗащищенноеСоединение(Элементы.ДекорацияСхема);
	
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура СерверПриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ПортПриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура АдресРесурсаПриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ПользовательПриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ПарольПриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ФрагментПриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры
#КонецОбласти
#КонецОбласти

#Область МОБИЛЬНОЕ_УСТРОЙСТВО
&НаКлиенте
Процедура ЗащищенноеСоединениеМППриИзменении(Элемент)
	ОформитьЗащищенноеСоединение(Элементы.ДекорацияСхемаМП);
	
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура СерверМППриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ПортМППриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура АдресРесурсаМППриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ФрагментМППриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ПользовательМППриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры

&НаКлиенте
Процедура ПарольМППриИзменении(Элемент)
	URI = ИдентификаторРесурса();
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
&НаКлиенте
Функция ИдентификаторРесурса()
	ЧастиURL = Новый Массив;
	ЧастиURL.Добавить(?(ЗащищенноеСоединение, "https://", "http://"));
	
	Если НЕ ПустаяСтрока(Пользователь) Тогда
		КоллекцияСтрок = Новый Структура("Пользователь, Пароль", Пользователь, Пароль);
		ЗакодированныеДанные = ЗакодированныеСтроки(КоллекцияСтрок);
		
		ЧастиURL.Добавить(ЗакодированныеДанные.Пользователь);
		Если НЕ ПустаяСтрока(ЗакодированныеДанные.Пароль) Тогда
			ЧастиURL.Добавить(":");
			ЧастиURL.Добавить(ЗакодированныеДанные.Пароль);
		КонецЕсли;
		ЧастиURL.Добавить("@");
	КонецЕсли;
	
	ЧастиURL.Добавить(СокрЛП(Сервер));
	
	Если ЗащищенноеСоединение И Порт <> 443 ИЛИ НЕ ЗащищенноеСоединение И Порт <> 80 Тогда
		ЧастиURL.Добавить(":");
		ЧастиURL.Добавить(XMLСтрока(Порт));
	КонецЕсли;
	
	АдресРесурса = СокрЛП(АдресРесурса);
	Если НЕ ПустаяСтрока(АдресРесурса) И НЕ СтрНачинаетсяС(АдресРесурса, "/") Тогда
		ЧастиURL.Добавить("/");
	КонецЕсли;
	
	ЧастиURL.Добавить(АдресРесурса);
	
	Фрагмент = СокрЛП(Фрагмент);
	Если НЕ ПустаяСтрока(Фрагмент) И СтрНачинаетсяС(Фрагмент, "#") Тогда
		Фрагмент = СокрЛ(Сред(Фрагмент, 2));
	КонецЕсли;
	
	Возврат СтрСоединить(ЧастиURL);
КонецФункции

&НаКлиенте
Процедура ОформитьЗащищенноеСоединение(ЭлементСхемы)
	Если ЗащищенноеСоединение Тогда
		ЭлементСхемы.Заголовок = "https://";
		
		Если Порт = 80 Тогда
			Порт = 443;
		КонецЕсли;
	Иначе
		ЭлементСхемы.Заголовок = "http://";
		
		Если Порт = 443 Тогда
			Порт = 80;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервереБезКонтекста
Функция ЗакодированныеСтроки(Знач КоллекцияСтрок)
	Возврат КлиентHTTP.ЗакодированныеСтроки(КоллекцияСтрок, СпособКодированияСтроки.КодировкаURL);
КонецФункции
#КонецОбласти
