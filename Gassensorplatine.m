% ------------------------Gassensorplatine Commands------------------------
%  1. multiplexerSwitch_TGS2620           Command: 0x01
%  2. multiplexerSwitch_TGS2611           Command: 0x02
%  3. multiplexerSwitch_TGS2610           Command: 0x03
%  4. multiplexerSwitch_TGS2602           Command: 0x04
%  5. multiplexerSwitch_TGS2600           Command: 0x05
%  6. multiplexer_Enable                  Command: 0x06
%  7. multiplexer_Disable                 Command: 0x07
%  8. measureADC                          Command: 0x08
%  9. measure_T_RH_High_Precision         Command: 0x09
% 10. measure_T_RH_Medium_Precision       Command: 0x0A
% 11. measure_T_RH_Low_Precision          Command: 0x0B
% 12. activateHeater_SHT45_200mW_1s       Command: 0x0C
% 13. activateHeater_SHT45_200mW_0_1s     Command: 0x0D
% 14. activateHeater_SHT45_110mW_1s       Command: 0x0E
% 15. activateHeater_SHT45_110mW_0_1s     Command: 0x0F
% 16. activateHeater_SHT45_20mW_1s        Command: 0x10
% 17. activateHeater_SHT45_20mW_0_1s      Command: 0x11
% 18. getSerialNumber_SHT45               Command: 0x12
% 19. softReset_SHT45                     Command: 0x13
% 20. conditioning_SGP41                  Command: 0x14
% 21. measure_VOC_NOX_noCompensation      Command: 0x15
% 22. measure_VOC_NOX_withCompensation    Command: 0x16
% 23. executeSelfTest_SGP41               Command: 0x17
% 24. idleMode_SGP41                      Command: 0x18
% 25. getSerialNumber_SGP41               Command: 0x19
% 26. LCD_enable                          Command: 0x1A
% 27. LCD_disable                         Command: 0x1B
% 28. clear_LCD_buffer                    Command: 0x1C
% -------------------------------------------------------------------------

%Clear Workspace
clear; 

%Open a UART Connection with Baudrate 115200
%(Determine Port via Device Manager)
s = serialport("COM5",115200);

%Disable LCD, if communicating with Matlab to enhance Performance
LCD_disable(s);
clear_LCD_buffer(s);
%--------------------------------------------------------------------------
% Write your Code here 
 adc_TGS2620 = zeros(1,21600);
 adc_TGS2611 = zeros(1,21600);
 adc_TGS2610 = zeros(1,21600);
 adc_TGS2602 = zeros(1,21600);
 adc_TGS2600 = zeros(1,21600);
 VOC = zeros(1,21600);
 NOX = zeros(1,21600);
 zeit_vorher = zeros(1,21600);
 zeit = zeros(1,21600);
 temperature = zeros(1,21600);
 humidity = zeros(1,21600);
 i = 1;

 figure();
 
 
 conditioning_SGP41(s);
 
 
 tic;
  while(toc < 300)
      if(toc - zeit_vorher >=5)
         zeit(i) = toc;
         zeit_vorher = zeit(i);

         multiplexerSwitch_TGS2620(s);
         pause(0.1);
         adc_TGS2620(i) = measureADC(s);
         multiplexerSwitch_TGS2611(s);
         pause(0.1);
         adc_TGS2611(i) = measureADC(s);
         multiplexerSwitch_TGS2610(s);
         pause(0.1);
         adc_TGS2610(i) = measureADC(s);
         multiplexerSwitch_TGS2602(s);
         pause(0.1);
         adc_TGS2602(i) = measureADC(s);
         multiplexerSwitch_TGS2600(s);
         pause(0.1);
         adc_TGS2600(i) = measureADC(s);         

         [VOC(i),NOX(i)] = measure_VOC_NOX_noCompensation(s);

         [temperature(i),humidity(i)] = measure_T_RH_High_Precision(s);

         i = i+1;

         plot(zeit,adc_TGS2600);
         drawnow();
      end
  end

  idleMode_SGP41(s);

%--------------------------Function Declarations --------------------------
% Switch Multiplexer to TGS2620
function switched = multiplexerSwitch_TGS2620(s)
    write(s,0x01,"char");
    if(read(s,1,"char") == 0x01)
        switched = 1;
    else
        switched = 0;
    end
end

% Switch Multiplexer to TGS2611
function switched = multiplexerSwitch_TGS2611(s)
    write(s,0x02,"char");
    if(read(s,1,"char") == 0x02)
        switched = 1;
    else
        switched = 0;
    end
end

% Switch Multiplexer to TGS2610
function switched = multiplexerSwitch_TGS2610(s)
    write(s,0x03,"char");
    if(read(s,1,"char") == 0x03)
        switched = 1;
    else
        switched = 0;
    end
end

% Switch Multiplexer to TGS2602
function switched = multiplexerSwitch_TGS2602(s)
    write(s,0x04,"char");
    if(read(s,1,"char") == 0x04)
        switched = 1;
    else
        switched = 0;
    end
end

% Switch Multiplexer to TGS2600
function switched = multiplexerSwitch_TGS2600(s)
    write(s,0x05,"char");
    if(read(s,1,"char") == 0x05)
        switched = 1;
    else
        switched = 0;
    end
end

function enabled = multiplexer_Enable(s)
    write(s,0x06,"char");
    if(read(s,1,"char") == 0x06)
        enabled = 1;
    else
        enabled = 0;
    end
end

function disabled = multiplexer_Disable(s)
    write(s,0x07,"char");
    if(read(s,1,"char") == 0x07)
        disabled = 1;
    else
        disabled = 0;
    end
end

function adc_value = measureADC(s)
    write(s,0x08,"char");
    if(read(s,1,"char") == 0x08)
        adc_value_high = read(s,1,"char");
        adc_value_low = read(s,1,"char");        
        adc_value = adc_value_high*256+adc_value_low;
    else
        adc_value = -1;
    end
end

function [temperature,humidity] = measure_T_RH_High_Precision(s)
    write(s,0x09,"char");
    if(read(s,1,"char") == 0x09)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = measure_T_RH_Medium_Precision(s)
    write(s,0x0A,"char");
    if(read(s,1,"char") == 0x0A)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = measure_T_RH_Low_Precision(s)
    write(s,0x0B,"char");
    if(read(s,1,"char") == 0x0B)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = activateHeater_SHT45_200mW_1s(s)
    write(s,0x0C,"char");
    if(read(s,1,"char") == 0x0C)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = activateHeater_SHT45_200mW_0_1s(s)
    write(s,0x0D,"char");
    if(read(s,1,"char") == 0x0D)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = activateHeater_SHT45_110mW_1s(s)
    write(s,0x0E,"char");
    if(read(s,1,"char") == 0x0E)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = activateHeater_SHT45_110mW_0_1s(s)
    write(s,0x0F,"char");
    if(read(s,1,"char") == 0x0F)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = activateHeater_SHT45_20mW_1s(s)
    write(s,0x10,"char");
    if(read(s,1,"char") == 0x10)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function [temperature,humidity] = activateHeater_SHT45_20mW_0_1s(s)
    write(s,0x11,"char");
    if(read(s,1,"char") == 0x11)
        temperature_high = read(s,1,"char");
        temperature_low  = read(s,1,"char");  
        temperature = temperature_high*256+temperature_low;
        humidity_high = read(s,1,"char");
        humidity_low  = read(s,1,"char");
        humidity = humidity_high*256+humidity_low;
    else
        temperature = -1;
        humidity = -1;
    end
end

function serialNumber = getSerialNumber_SHT45(s)
    write(s,0x12,"char");
    if(read(s,1,"char") == 0x12)
        serialNumber = read(s,4,"char");
        serialNumber = serialNumber(1)+serialNumber(2)*256+serialNumber(3)*65536+serialNumber(4)*16777216;
    else
        serialNumber =-1;
    end
end

function reset = softReset_SHT45(s)
    write(s,0x13,"char");
    if(read(s,1,"char") == 0x13)
        reset = 1;
    else
        reset = 0;
    end
end

function VOC = conditioning_SGP41(s)
    write(s,0x14,"char");
    if(read(s,1,"char") == 0x14)
        VOC = read(s,2,"char");
        VOC = VOC(2)+VOC(1)*256;
    else
        VOC = -1;
    end
end

function [VOC,NOX] = measure_VOC_NOX_noCompensation(s)
    write(s,0x15,"char")
    if(read(s,1,"char") == 0x15)
        VOC = read(s,2,"char");
        VOC = VOC(2)+VOC(1)*256;

        NOX = read(s,2,"char");
        NOX = NOX(2)+NOX(1)*256;
    else
        VOC = -1;
        NOX = -1;
    end
end

function [VOC,NOX] = measure_VOC_NOX_withCompensation(s)
    write(s,0x16,"char")
    if(read(s,1,"char") == 0x16)
        VOC = read(s,2,"char");
        VOC = VOC(2)+VOC(1)*256;

        NOX = read(s,2,"char");
        NOX = NOX(2)+NOX(1)*256;
    else
        VOC = -1;
        NOX = -1;
    end
end

function selftest = executeSelfTest_SGP41(s)
    write(s,0x17,"char");
    if(read(s,1,"char") == 0x17)
        selftest_high = read(s,1,"char");
        selftest_low  = read(s,1,"uint8");
        selftest_low = bitand(selftest_low,0x03);
        if(selftest_low == 0x00)
            selftest = 1;
        else
            selftest = -1;
        end        
    else
        selftest = -1;
    end
end

function idle = idleMode_SGP41(s)
    write(s,0x18,"char");
    if(read(s,1,"char") == 0x18)
        idle = 1;
    else
        idle = -1;
    end
end

function serialNumber = getSerialNumber_SGP41(s)
    write(s,0x19,"char");
    if(read(s,1,"char") == 0x19)
        serialNumber_high = read(s,1,"uint32");
        serialNumber_low  = read(s,1,"uint16");
        serialNumber = serialNumber_low+serialNumber_high*65536;
    else
        serialNumber = -1;
    end
end

function enable = LCD_enable(s)
    write(s,0x1A,"char");
    if(read(s,1,"char") == 0x1A)
        enable = 1;
    else
        enable = -1;
    end
end

function disable = LCD_disable(s)
    write(s,0x1B,"char");
    if(read(s,1,"char") == 0x1B)
        disable = 1;
    else
        disable = -1;
    end
end

function cleared = clear_LCD_buffer(s)
    write(s,0x1C,"char");
    if(read(s,1,"char") == 0x1C)
        cleared = 1;
    else
        cleared = -1;
    end
end