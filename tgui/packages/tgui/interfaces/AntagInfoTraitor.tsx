import { useBackend } from '../backend';
import { multiline } from 'common/string';
import { BlockQuote, Button, Dimmer, Section, Stack } from '../components';
import { BooleanLike } from 'common/react';
import { Window } from '../layouts';

const allystyle = {
  fontWeight: 'bold',
  color: 'yellow',
};

const badstyle = {
  color: 'red',
  fontWeight: 'bold',
};

const goalstyle = {
  color: 'lightblue',
  fontWeight: 'bold',
};

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type Info = {
  has_codewords: BooleanLike;
  phrases: string;
  responses: string;
  theme: string;
  allies: string;
  goal: string;
  intro: string;
  code: string;
  failsafe_code: string;
  replacement_code: string;
  replacement_frequency: string;
  has_uplink: BooleanLike;
  uplink_intro: string;
  uplink_unlock_info: string;
  objectives: Objective[];
};

const ObjectivePrintout = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Your current objectives:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'None!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};

const IntroductionSection = (props, context) => {
  const { act, data } = useBackend<Info>(context);
  const { intro } = data;
  return (
    <Section fill title="Intro" scrollable>
      <Stack vertical fill>
        <Stack.Item fontSize="25px">{intro}</Stack.Item>
        <Stack.Item grow>
          <ObjectivePrintout />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EmployerSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { allies, goal } = data;
  return (
    <Section
      fill
      title="Employer"
      scrollable
      buttons={
        <Button
          icon="hammer"
          tooltip={multiline`
            This is a gameplay suggestion for bored traitors.
            You don't have to follow it, unless you want some
            ideas for how to spend the round.`}
          tooltipPosition="bottom-start">
          Policy
        </Button>
      }>
      <Stack vertical fill>
        <Stack.Item grow>
          <Stack vertical>
            <Stack.Item>
              <span style={allystyle}>
                Your allegiances:
                <br />
              </span>
              <BlockQuote>{allies}</BlockQuote>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              <span style={goalstyle}>
                Employer thoughts:
                <br />
              </span>
              <BlockQuote>{goal}</BlockQuote>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const UplinkSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const {
    has_uplink,
    uplink_intro,
    uplink_unlock_info,
    code,
    failsafe_code,
    replacement_code,
    replacement_frequency,
  } = data;
  return (
    <Section title="Uplink" mb={!has_uplink && -1}>
      <Stack fill>
        {(!has_uplink && (
          <Dimmer>
            <Stack.Item fontSize="16px">
              <Section textAlign="Center">
                Your uplink is missing or destroyed. <br />
                Craft a Syndicate Uplink Beacon and then speak
                <br />
                <span style={goalstyle}>
                  <b>{replacement_code}</b>
                </span>{' '}
                on frequency{' '}
                <span style={goalstyle}>
                  <b>{replacement_frequency}</b>
                </span>{' '}
                after synchronizing with the beacon.
              </Section>
            </Stack.Item>
          </Dimmer>
        )) || (
          <>
            <Stack.Item bold>
              {uplink_intro}
              <br />
              {code && <span style={goalstyle}>Code: {code}</span>}
              <br />
              {failsafe_code && (
                <span style={badstyle}>Failsafe: {failsafe_code}</span>
              )}
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item mt="1%">
              <BlockQuote>{uplink_unlock_info}</BlockQuote>
            </Stack.Item>
          </>
        )}
      </Stack>
      <br />
      {(has_uplink && (
        <Section textAlign="Center">
          If you lose your uplink, you can craft a Syndicate Uplink Beacon and
          then speak{' '}
          <span style={goalstyle}>
            <b>{replacement_code}</b>
          </span>{' '}
          on radio frequency{' '}
          <span style={goalstyle}>
            <b>{replacement_frequency}</b>
          </span>{' '}
          after synchronizing with the beacon.
        </Section>
      )) || (
        <Section>
          {' '}
          <br />
          <br />
        </Section>
      )}
    </Section>
  );
};

const CodewordsSection = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { has_codewords, phrases, responses } = data;
  return (
    <Section title="Codewords" mb={!has_codewords && -1}>
      <Stack fill>
        {(!has_codewords && (
          <BlockQuote>
            You have not been supplied with codewords. You will have to use
            alternative methods to find potential allies. Proceed with caution,
            however, as everyone is a potential foe.
          </BlockQuote>
        )) || (
          <>
            <Stack.Item grow basis={0}>
              <BlockQuote>
                Your employer provided you with the following codewords to
                identify fellow agents. Use the codewords during regular
                conversation to identify other agents. Proceed with caution,
                however, as everyone is a potential foe.
                <span style={badstyle}>
                  &ensp;You have memorized the codewords, allowing you to
                  recognise them when heard.
                </span>
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider mr={1} />
            <Stack.Item grow basis={0}>
              <Stack vertical>
                <Stack.Item>Code Phrases:</Stack.Item>
                <Stack.Item bold textColor="blue">
                  {phrases}
                </Stack.Item>
                <Stack.Item>Code Responses:</Stack.Item>
                <Stack.Item bold textColor="red">
                  {responses}
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

export const AntagInfoTraitor = (props, context) => {
  const { data } = useBackend<Info>(context);
  const { theme } = data;
  return (
    <Window width={620} height={580} theme={theme}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="70%">
                <IntroductionSection />
              </Stack.Item>
              <Stack.Item width="30%">
                <EmployerSection />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item>
            <UplinkSection />
          </Stack.Item>
          <Stack.Item>
            <CodewordsSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
