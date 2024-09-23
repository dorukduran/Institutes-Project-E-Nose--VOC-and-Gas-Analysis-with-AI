figure();
plot(zeit(1:4319),adc_TGS2620(1:4319));
hold on;
plot(zeit(1:4319),adc_TGS2611(1:4319));
plot(zeit(1:4319),adc_TGS2610(1:4319));
plot(zeit(1:4319),adc_TGS2602(1:4319));
plot(zeit(1:4319),adc_TGS2600(1:4319));
xlabel("Time");
ylabel("ADC_Value");
grid minor;
axis([0 21600 0 16384]);
yyaxis right;
temperature_neu = -45+175*(temperature/65535);
plot(zeit(1:4319),temperature_neu(1:4319));
legend('TGS2620','TGS2611','TGS2610','TGS2602','TGS2600','Temperature');

figure();
plot(zeit(1:4319),adc_TGS2620(1:4319));
hold on;
plot(zeit(1:4319),adc_TGS2611(1:4319));
plot(zeit(1:4319),adc_TGS2610(1:4319));
plot(zeit(1:4319),adc_TGS2602(1:4319));
plot(zeit(1:4319),adc_TGS2600(1:4319));
xlabel("Time");
ylabel("ADC_Value");
grid minor;
axis([0 21600 0 16384]);
yyaxis right;
humidity_neu = -6+125*(humidity/65535);
plot(zeit(1:4319),humidity_neu(1:4319));
legend('TGS2620','TGS2611','TGS2610','TGS2602','TGS2600','Humidity');

figure();
plot(zeit(1:4319),VOC(1:4319));
hold on;
plot(zeit(1:4319),NOX(1:4319));
xlabel("Time");
ylabel("ADC_Value");
grid minor;
axis([0 21600 0 65535]);
yyaxis right;
plot(zeit(1:4319),temperature_neu(1:4319));
legend('VOC','NOX','Temperature');

figure();
plot(zeit(1:4319),VOC(1:4319));
hold on;
plot(zeit(1:4319),NOX(1:4319));
xlabel("Time");
ylabel("ADC_Value");
grid minor;
axis([0 21600 0 65535]);
yyaxis right;
plot(zeit(1:4319),humidity_neu(1:4319));
legend('VOC','NOX','humidity');