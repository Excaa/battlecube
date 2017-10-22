import { app, h } from 'hyperapp';
import { div, h1, main, label, button } from '@hyperapp/html';
import './client.css';
import state, { GameStatus, IAppState, IPlayer } from './initialState';
import { LogItem, Slider, Player, Setup } from './views';
import actions, { IActions } from './actions';
import renderCube from './cube';
import botForm, { renderBotForm } from './botFormModule';
import syncActionsAndInjectEmitter from './enhancer';

const enhancedApp = syncActionsAndInjectEmitter(app);

enhancedApp(
  {
    state,
    actions,
    init: (state: IAppState, actions: IActions): void => {
      actions.updateGameStatus();
      actions.log();
    },
    events: {
      reinit: (state: IAppState, actions: IActions, data: any) => {
        state.cube.resize(data.edgeLength);
      }
    },
    modules: { botForm },
    view: (state: IAppState, actions: IActions) =>
      main({}, [
        h1({}, 'Battle³'),
        Setup(state, actions),
        label({}, `Speed: ${state.sliderSpeedValue} ms`),
        Slider(state, actions),
        button(
          {
            disabled: state.gameStatus === GameStatus.started,
            onclick: () => actions.start()
          },
          'Start game'
        ),
        renderCube(state, actions),
        div(
          {
            className: 'log',
            style: { display: state.log.length < 1 ? 'none' : 'flex' }
          },
          [h('ul', {}, state.log.map(LogItem(state.players)))]
        ),
        div(
          { className: 'players' },
          state.players.map((p: IPlayer, index: number) =>
            Player(
              p,
              index,
              state.players.filter(p => p.status === 1).length === 1,
              actions
            )
          )
        ),
        renderBotForm(state, actions),
        button(
          {
            disabled: state.gameStatus === GameStatus.started,
            onclick: () => actions.botForm.toggleForm()
          },
          state.botForm.isOpen ? 'Close' : 'Add bot'
        )
      ])
  },
  document.getElementById('app')
);
