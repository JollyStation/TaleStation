/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { storage } from 'common/storage';
import { setClientTheme } from '../themes';
import { loadSettings, updateSettings, addHighlightSetting, removeHighlightSetting, updateHighlightSetting } from './actions';
import { selectSettings } from './selectors';
import { FONTS_DISABLED } from './constants';

<<<<<<< HEAD
const setGlobalFontSize = (fontSize) => {
  document.documentElement.style.setProperty('font-size', fontSize + 'px');
  document.body.style.setProperty('font-size', fontSize + 'px');
=======
let overrideRule = null;
let overrideFontFamily = null;
let overrideFontSize = null;

const updateGlobalOverrideRule = () => {
  let fontFamily = '';

  if (overrideFontFamily !== null) {
    fontFamily = `font-family: ${overrideFontFamily} !important;`;
  }

  const constructedRule = `body * :not(.Icon) {
    ${fontFamily}
  }`;

  if (overrideRule === null) {
    overrideRule = document.createElement('style');
    document.querySelector('head').append(overrideRule);
  }

  // no other way to force a CSS refresh other than to update its innerText
  overrideRule.innerText = constructedRule;

  document.body.style.setProperty('font-size', overrideFontSize);
};

const setGlobalFontSize = (fontSize) => {
  overrideFontSize = `${fontSize}px`;
>>>>>>> 6c6d6a1db22b9 (Revert font scaling in TGUI chat back to its prior implementation (#78708))
};

const setGlobalFontFamily = (fontFamily) => {
  if (fontFamily === FONTS_DISABLED) fontFamily = null;

  document.documentElement.style.setProperty('font-family', fontFamily);
  document.body.style.setProperty('font-family', fontFamily);
};

export const settingsMiddleware = (store) => {
  let initialized = false;
  return (next) => (action) => {
    const { type, payload } = action;
    if (!initialized) {
      initialized = true;
      storage.get('panel-settings').then((settings) => {
        store.dispatch(loadSettings(settings));
      });
    }
    if (
      type === updateSettings.type ||
      type === loadSettings.type ||
      type === addHighlightSetting.type ||
      type === removeHighlightSetting.type ||
      type === updateHighlightSetting.type
    ) {
      // Set client theme
      const theme = payload?.theme;
      if (theme) {
        setClientTheme(theme);
      }
      // Pass action to get an updated state
      next(action);
      const settings = selectSettings(store.getState());
      // Update global UI font size
      setGlobalFontSize(settings.fontSize);
      setGlobalFontFamily(settings.fontFamily);
      // Save settings to the web storage
      storage.set('panel-settings', settings);
      return;
    }
    return next(action);
  };
};
