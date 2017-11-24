import { h } from 'hyperapp';
import { div, main, label, button, ul } from '@hyperapp/html';
import { GameStatus, IAppState, IPlayer } from '../initialState';
import { LogItem, Slider, Player, Setup, ErrorNotification } from '../partials';
import { IActions } from '../actions';
import renderCube from '../visuals/cube';
import { renderBotForm } from '../modules/botFormModule';
import { sortByProp } from '../helpers';

export default (state: IAppState, actions: IActions) =>
  main({}, [
    Setup(state, actions),
    label({}, `Speed: ${state.sliderSpeedValue} ms`),
    Slider(state, actions),
    ErrorNotification(state.error),
    button(
      {
        disabled: state.gameStatus === GameStatus.started,
        id:"startGameBtn",
        onclick: () => actions.start()
      },
      'Start game'
    ),
    div({}, [renderCube(state, actions)]),
    div(
      {
        className: 'log',
        style: { display: state.log.length < 1 ? 'none' : 'flex' }
      },
      [ul({}, state.log.map(LogItem(state.players)))]
    ),
    div(
      { className: 'players' },
      sortByProp('wins', state.players)
        .reverse()
        .map((p: IPlayer, index: number) =>
          Player(
            p,
            index,
            state.players.filter(p => p.status === 1).length === 1,
            actions
          )
        )
    ),
    div({ className: 'player-form-container' }, [
      renderBotForm(state, actions)
    ]),
    button(
      {
        disabled: state.gameStatus === GameStatus.started,
        onclick: () => actions.botForm.toggleForm()
      },
      state.botForm.isOpen ? 'Close' : 'Add bot'
    )
  ]);
