/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

<<<<<<< HEAD:tgui/packages/tgui/layouts/NtosWindow.jsx
=======
import { BooleanLike } from 'common/react';

>>>>>>> 6ccb751678c11 (Updates eslint + sorts imports (#80430)):tgui/packages/tgui/layouts/NtosWindow.tsx
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Box, Button } from '../components';
import { Window } from './Window';

export const NtosWindow = (props) => {
  const { title, width = 575, height = 700, children } = props;
  const { act, data } = useBackend();
  const {
    PC_device_theme,
    PC_batteryicon,
    PC_batterypercent,
    PC_ntneticon,
    PC_stationdate,
    PC_stationtime,
    PC_programheaders = [],
    PC_showexitprogram,
    PC_lowpower_mode,
  } = data;
  return (
    <Window title={title} width={width} height={height} theme={PC_device_theme}>
      <div className="NtosWindow">
        <div className="NtosWindow__header NtosHeader">
          <div className="NtosHeader__left">
            <Box inline bold mr={2}>
              <Button
                width="26px"
                lineHeight="22px"
                textAlign="left"
                tooltip={PC_stationdate}
                color="transparent"
                icon="calendar"
                tooltipPosition="bottom"
              />
              {PC_stationtime}
            </Box>
            <Box inline italic mr={2} opacity={0.33}>
              {(PC_device_theme === 'syndicate' && 'Syndix') || 'NtOS'}
              {!!PC_lowpower_mode && ' - RUNNING ON LOW POWER MODE'}
            </Box>
          </div>
          <div className="NtosHeader__right">
            {PC_programheaders.map((header) => (
              <Box key={header.icon} inline mr={1}>
                <img
                  className="NtosHeader__icon"
                  src={resolveAsset(header.icon)}
                />
              </Box>
            ))}
            <Box inline>
              {PC_ntneticon && (
                <img
                  className="NtosHeader__icon"
                  src={resolveAsset(PC_ntneticon)}
                />
              )}
            </Box>
            {!!PC_batteryicon && (
              <Box inline mr={1}>
                <img
                  className="NtosHeader__icon"
                  src={resolveAsset(PC_batteryicon)}
                />
                {PC_batterypercent && PC_batterypercent}
              </Box>
            )}
            {!!PC_showexitprogram && (
              <Button
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="window-minimize-o"
                tooltip="Minimize"
                tooltipPosition="bottom"
                onClick={() => act('PC_minimize')}
              />
            )}
            {!!PC_showexitprogram && (
              <Button
                mr="-3px"
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="window-close-o"
                tooltip="Close"
                tooltipPosition="bottom-start"
                onClick={() => act('PC_exit')}
              />
            )}
            {!PC_showexitprogram && (
              <Button
                mr="-3px"
                width="26px"
                lineHeight="22px"
                textAlign="center"
                color="transparent"
                icon="power-off"
                tooltip="Power off"
                tooltipPosition="bottom-start"
                onClick={() => act('PC_shutdown')}
              />
            )}
          </div>
        </div>
        {children}
      </div>
    </Window>
  );
};

const NtosWindowContent = (props) => {
  return (
    <div className="NtosWindow__content">
      <Window.Content {...props} />
    </div>
  );
};

NtosWindow.Content = NtosWindowContent;
