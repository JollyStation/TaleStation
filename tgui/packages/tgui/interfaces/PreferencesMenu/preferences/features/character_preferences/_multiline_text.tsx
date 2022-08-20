import { Feature, FeatureValueProps, FeatureShortTextInput } from '../base';
import { Stack, TextArea } from '../../../../../components';

export const MultilineText = (props: FeatureValueProps<string, string>) => {
  const { handleSetValue, value } = props;
  return (
    <Stack>
      <Stack.Item grow>
        <TextArea
          width="80%"
          height="52px"
          value={value}
          onInput={(e, value) => {
            handleSetValue(value);
          }}
        />
      </Stack.Item>
    </Stack>
  );
};

export const flavor_text: Feature<string, string> = {
  name: 'Flavor - Flavor Text',
  component: MultilineText,
};

export const exploitable_info: Feature<string, string> = {
  name: 'Flavor - Exploitable Info',
  component: MultilineText,
};

export const general_records: Feature<string, string> = {
  name: 'Flavor - General Records',
  component: MultilineText,
};

export const security_records: Feature<string, string> = {
  name: 'Flavor - Security Records',
  component: MultilineText,
};

export const medical_records: Feature<string, string> = {
  name: 'Flavor - Medical Records',
  component: MultilineText,
};

export const silicon_flavor_text: Feature<string> = {
  name: 'Flavor Text (Silicon)',
  description: 'Describe your cyborg/AI shell!',
  component: MultilineText,
};

export const ooc_notes: Feature<string> = {
  name: 'OOC Notes',
  description: 'Give some OOC information.',
  component: MultilineText,
};

export const headshot: Feature<string> = {
  name: 'Headshot',
  description:
    'Add an image to your character, visible on close examination. Requires it be formatted properly.',
  component: FeatureShortTextInput,
};

export const custom_species: Feature<string> = {
  name: 'Custom Species Name',
  description:
    "Want to have a fancy species name? Put it here, or leave it blank if you want to use your species' default name.",
  component: FeatureShortTextInput,
};

export const custom_species_lore: Feature<string> = {
  name: 'Custom Species Lore',
  description:
    "Add some lore for your species! Won't show up if there's no custom species.",
  component: MultilineText,
};
