#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import visual, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
from pull_timings import *
import pandas as pd
import random
import os  # handy system and path functions
import csv
import time
# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)


b1=['semantic', 'self', 'other',  'other', 'self',  'other', 'self',  'self', 'other','semantic']
b2=['self', 'other',  'other', 'semantic', 'self',  'other', 'semantic', 'self',  'self', 'other']
b3=['other', 'self', 'semantic',  'self', 'other',  'self', 'other',  'semantic', 'other','self']

block_versions = [b1, b2, b3]
random.shuffle(block_versions)

block_order = pd.DataFrame({'block': np.arange(10), 
    'block_type': block_versions[0]})

# Store info about the experiment session
expName = 'task-selfref_run-01'  # from the Builder filename that created this script
expInfo = {'participant':'', 'session':1, 'run':1, 'friend_name':''}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

if not os.path.exists(f'{_thisDir}/reMIND/'):
    os.mkdir(f'{_thisDir}/reMIND/')

if not os.path.exists(f"{_thisDir}/reMIND/{expInfo['participant']}"):
    os.mkdir(f"{_thisDir}/reMIND/{expInfo['participant']}")

# pull word order for the participant
participant_number = int(expInfo['participant'][-3:])
word_order_file = f"word_list_splits/word_order_{participant_number}.csv"
word_order = pd.read_csv(word_order_file)
word_list = word_order[word_order.run == expInfo['run']]

negative_words = list(word_list.word[word_list.valence_condition == '-'])
positive_words = list(word_list.word[word_list.valence_condition == '+']) 
random.shuffle(positive_words)
random.shuffle(negative_words)
practice_words = ['polite', 'bossy', 'rude', 'cool', 'nice', 'jealous']

print(negative_words)
print(positive_words)

# output file setm
filename = f"{_thisDir}/reMIND/{expInfo['participant']}/reMIND_ses{expInfo['session']}_task-selfref_run_{expInfo['run']}"

def write_to_tsv(row_info:list):
    with open(filename+'_events.csv', 'a') as csvfile:
        stim_writer = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        stim_writer.writerow(row_info)
 
write_to_tsv(['participant','session', 'date', 'exp_name', 'frame_rate', 'absolute_time', 'trigger_time', 'trial_type', 'trial_num', 'word', 'response_time','reponse_key', 'condition', 'word_valence'])

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)
trial_duration = 2.5
block_intro_time = 2

# Setup the Window
win = visual.Window(size=(1920, 1080), fullscr=True, screen=1, allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[-1,-1,-1], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    )

# Initialize components for Routine "instruct"
instructClock = core.Clock()
instruct_text = visual.TextStim(win=win, ori=0, name='instruct_text',
    text=u"Welcome!\n\nDuring this task you'll answer a series of YES or NO questions.\
\n\nYou'll have a chance to answer 3 different types of questions.", font='Arial',
    pos=[0.0, 0], height=0.08, wrapWidth=1.5,
    color='white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "trigger"
triggerClock = core.Clock()
trial_clock = core.Clock()
text_3 = visual.TextStim(win=win, ori=0, name='text_3',
    text=u'waiting for scanner to begin...',    font=u'Arial',
    pos=[0, 0], height=0.1, wrapWidth=2,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)

# Initialize components for Routine "fixation"
fixationClock = core.Clock()

fix_stim = visual.TextStim(win=win, ori=0, name='fix_stim',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


controlClock = core.Clock()
prefix = visual.TextStim(win=win, ori=0, name='prefix',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=0.0)


word = visual.TextStim(win=win, ori=0, name='word',
    text='default text',    font=u'Arial',
    pos=[0, -0.2], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

yes = visual.TextStim(win=win, ori=0, name='word',
    text='YES',    font=u'Arial',
    pos=[0.7, -.8], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

no = visual.TextStim(win=win, ori=0, name='word',
    text='NO',    font=u'Arial',
    pos=[-0.7, -.8], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)
    

block_type_text = visual.TextStim(win=win, ori=0, name='word',
    text='block_text',    font=u'Arial',
    pos=[0.0, 0.2], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-1.0)

postfix = visual.TextStim(win=win, ori=0, name='postfix',
    text=u'+',    font=u'Arial',
    pos=[0, 0], height=0.2, wrapWidth=None,
    color=u'white', colorSpace='rgb', opacity=1,
    depth=-2.0)


# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

def run_instructions():
    instruct_text.draw()
    win.flip()
    wait_for_keypress(['space'])
    write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                    expName, expInfo['frameRate'], time.time(), '', 'instructions', '', '', '','', '', ''])


def wait_for_keypress(key_list:list):
    continueRoutine = True
    while continueRoutine:
        theseKeys = event.getKeys(keyList=key_list)
        if len(theseKeys) > 0:  # at least one key was pressed
                # a response ends the routine
                continueRoutine = False


'''
Get trigger
'''
def get_trigger():
    #trigger_resp = event.BuilderKeyResponse()
    #trigger_resp = NOT_STARTED
    event.clearEvents(eventType='keyboard')
    text_3.draw()
    win.flip()
    triggerClock.reset()
    continueRoutine = True
    while continueRoutine:
        theseKeys = event.getKeys(keyList=['t'])
        if len(theseKeys) > 0:  # at least one key was pressed
                trigger_rt = triggerClock.getTime()
                triggerClock.reset()
                print(trigger_rt)
                # a response ends the routine
                continueRoutine = False
                write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                    expName, expInfo['frameRate'], time.time(), 0, 'trigger', '', '', '','', '', ''])

'''
Run a block of trials
'''
def run_block(n_trials, block_type, block_number, practice=False):
    if block_type == 'semantic':
        block_type_text.setText(f'Is the word positive?')
    elif block_type == 'self':
        block_type_text.setText(f'Does this word describe you?')
    elif block_type == 'other':
        block_type_text.setText(f'Does this word describe {expInfo["friend_name"]}?')
    block_type_text.height = 0.2    
    block_type_text.draw()
    win.flip()
    
    # Show questions for longer during practice
    if not practice:
        core.wait(block_intro_time)
    elif practice:
        core.wait(4)
    if block_type == 'semantic':
        block_type_text.setText(f'Is this word positive?')
    elif block_type == 'self':
        block_type_text.setText(f'Are you?')
    elif block_type == 'other':
        block_type_text.setText(f'Is {expInfo["friend_name"]}?')
    block_type_text.height = 0.08
    if not practice:
        # get timings just for the current block
        block_timing_frame = all_block_timings[all_block_timings.block == block_number]
        block_timing_frame.reset_index(inplace = True)

        # run each trial in the block, pulling the word type (positive vs. negative) and fixation duration (ISI) from the block_timing_frame
        for trial_num in range(n_trials):
            run_trial(trial_type = block_timing_frame.stim_type[trial_num], fixation_duration= block_timing_frame.fix_duration[trial_num],practice=False, block_type=block_type)

'''
Show a fixation cross 
'''
def run_fixation(duration):
    # present fixation
    fix_stim.draw()
    win.flip()
    fix_time = core.StaticPeriod(screenHz=expInfo['frameRate'])
    fix_time.start(duration) 
    fix_time.complete() 
    write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                    expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'fixation', 1, '', '','', '', ''])
    event.clearEvents(eventType='keyboard')

'''
Run a single trial
'''
def run_trial(trial_type, fixation_duration, practice=False, block_type=''):
    
    # fixation at beginning of trial
    run_fixation(duration=fixation_duration)
    # present word 
    trial_clock.reset()
    if not practice:
        if trial_type == 'negative':
            trial_word = negative_words.pop(0)
        elif trial_type == 'positive':
            trial_word = positive_words.pop(0)
    elif practice:
        trial_word = practice_words.pop(0)
    word.setText(trial_word)
    endExpNow = False
    no.bold = False
    no.italic = False
    yes.bold = False
    yes.italic = False
    word.draw()
    yes.draw()
    no.draw()
    block_type_text.draw()
    win.flip()
    if not practice:
        write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                        expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'word_presentation', 1, trial_word, '', '', block_type, trial_type])
    
    # get participant button press response for word
    continueRoutine = True
    while continueRoutine:            
        trial_time = trial_clock.getTime()
        if trial_time > 0 and trial_time < trial_duration:
            theseKeys = event.getKeys(keyList=['2', '3', 'escape'])
            if "escape" in theseKeys:
                endExpNow = True

            # if participant has pressed a button    
            if len(theseKeys) > 0:
                if not practice:  
                    write_to_tsv([expInfo['participant'],expInfo['session'], expInfo['date'], 
                                    expName, expInfo['frameRate'], time.time(), triggerClock.getTime(), 'response', 1, 
                                    trial_word, trial_clock.getTime(), theseKeys[0], block_type, trial_type])
                # change color of selected word
                if '2' in theseKeys:
                    no.bold = True
                    no.italic = True
                elif '3' in theseKeys:
                    yes.bold = True
                    yes.italic = True
                word.draw()
                yes.draw()
                no.draw()
                block_type_text.draw()
                win.flip()
            if endExpNow:
                win.close()
                core.quit()
        else:
            continueRoutine = False 
            if endExpNow:
                core.quit()
                core.quit()      


def run_practice():
    instruct_text.setText(f'The 3 types of YES or NO questions you will see will be:\
\n\n1) Does a word describe you?\
\n\n2) Does a word describe {expInfo["friend_name"]} (who you mentioned earlier)?\
\n\n3) Is a word positive?')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])
    instruct_text.setText('Each time you answer a question:\
        \n\n\npress with your index finger to answer NO\n\npress with your middle finger to answer YES')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])
    instruct_text.setText('Just to make sure everything is working with the buttons.\
        \n\nPlease press your index finger to answer NO')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['2'])
    instruct_text.setText('Just to make sure everything is working with the buttons.\
        \n\nPlease press your middle finger to answer YES')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['3'])
    instruct_text.setText('Great! We will go through a few practice trials of each type now.\
        \n\nTry to make your decision quickly!')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])

    # Run actual practice trials
    run_block(n_trials = 0, block_type = 'self', block_number = 0, practice = True)
    run_trial(trial_type = 'self', fixation_duration=1, practice = True, block_type = 'self')
    run_trial(trial_type = 'self', fixation_duration=1, practice = True, block_type = 'self')
    run_block(n_trials = 0, block_type = 'other', block_number = 0, practice = True)
    run_trial(trial_type = 'other', fixation_duration=1, practice = True, block_type = 'other')
    run_trial(trial_type = 'other', fixation_duration=1, practice = True, block_type = 'other')
    run_block(n_trials = 0, block_type = 'semantic', block_number = 0, practice = True)
    run_trial(trial_type = 'positive', fixation_duration=1, practice = True, block_type = 'semantic')
    run_trial(trial_type = 'positive', fixation_duration=1, practice = True, block_type = 'semantic')
    instruct_text.setText('Great job! Any questions on what to do?')
    instruct_text.draw()
    win.flip()
    wait_for_keypress(key_list=['space'])



'''
Actually run everything!
'''

run_instructions()

# only run practice if it is run 1
if expInfo['run'] == 1:
    run_practice()
get_trigger()

for block_num in range(block_order.shape[0]):
    run_fixation(8)
    run_block(n_trials = 6, block_type = block_order.block_type[block_num], block_number = block_num)

instruct_text.setText('Great job! You have finished this run')
instruct_text.draw()
win.flip()
core.wait(3)
win.close()
core.quit()


